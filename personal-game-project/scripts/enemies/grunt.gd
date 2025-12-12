extends CharacterBody2D

@export var move_speed: float = 150.0
@export var max_health: int = 20

@export var touch_damage: int = 10
@export var attack_interval: float = 0.8
@export var attack_anim_duration: float = 0.25

var health: int = 0
var target: Node2D = null

var _attack_cooldown: float = 0.0
var _attack_timer: float = 0.0
var _player_in_range: Node2D = null

var _is_dead: bool = false
var _is_hurt: bool = false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var fx_anim: AnimatedSprite2D = $FX


func _ready() -> void:
	health = max_health

	# Find player
	target = get_tree().get_first_node_in_group("player")
	if target == null:
		print("Grunt: no player found in group 'player'!")

	if anim:
		anim.play("idle")

	if fx_anim:
		fx_anim.visible = false


func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	_attack_cooldown -= delta
	_attack_timer = max(_attack_timer - delta, 0.0)

	if target == null or not is_instance_valid(target):
		velocity = Vector2.ZERO
		move_and_slide()
		_update_animation()
		return

	# Move toward player
	var dir: Vector2 = target.global_position - global_position
	if dir.length() > 5.0:
		velocity = dir.normalized() * move_speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	# Try to attack if player is inside AttackArea and cooldown ready
	if _player_in_range != null and _attack_cooldown <= 0.0:
		_attack_cooldown = attack_interval
		_attack_target()

	_update_animation()


func _update_animation() -> void:
	if anim == null:
		return

	if _is_dead:
		if anim.animation != "death":
			anim.play("death")
		return

	if _attack_timer > 0.0:
		if anim.animation != "attack":
			anim.play("attack")
		return

	if velocity.length() > 0.0:
		if anim.animation != "run":
			anim.play("run")
	else:
		if anim.animation != "idle":
			anim.play("idle")


func _attack_target() -> void:
	if _player_in_range == null or not is_instance_valid(_player_in_range):
		return

	_attack_timer = attack_anim_duration

	if _player_in_range.has_method("apply_damage"):
		_player_in_range.apply_damage(touch_damage)

	_play_attack_fx()


func _play_attack_fx() -> void:
	if fx_anim == null:
		return
	fx_anim.visible = true
	fx_anim.play("attack_fx")


func _on_FX_animation_finished() -> void:
	# Hide FX when its animation ends
	if fx_anim:
		fx_anim.visible = false


func apply_damage(amount: int) -> void:
	if _is_dead:
		return

	health -= amount
	print("Grunt took ", amount, " damage. Health: ", health, "/", max_health)

	if health <= 0:
		die()
	else:
		if not _is_hurt:
			_play_hurt_blink()


func _play_hurt_blink() -> void:
	_is_hurt = true
	_hurt_blink_coroutine()


func _hurt_blink_coroutine() -> void:
	var original_modulate: Color = anim.modulate

	# Blink a few times: alpha 0.3 <-> 1.0
	for i in range(4):
		if _is_dead:
			break
		anim.modulate.a = 0.3
		await get_tree().create_timer(0.05).timeout
		if _is_dead:
			break
		anim.modulate.a = 1.0
		await get_tree().create_timer(0.05).timeout

	anim.modulate = original_modulate
	_is_hurt = false


func die() -> void:
	if _is_dead:
		return

	_is_dead = true
	velocity = Vector2.ZERO
	_player_in_range = null

	if fx_anim:
		fx_anim.visible = true
		fx_anim.play("death_fx")

	if anim:
		anim.play("death")

	_death_wait_and_free()


func _death_wait_and_free() -> void:
	if anim:
		await anim.animation_finished
	queue_free()


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = body


func _on_attack_area_body_exited(body: Node2D) -> void:
	if body == _player_in_range:
		_player_in_range = null
