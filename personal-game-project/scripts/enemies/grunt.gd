extends CharacterBody2D

@export var move_speed: float = 150.0
@export var max_health: int = 20

@export var touch_damage: int = 10
@export var attack_interval: float = 0.8

var health: int = 0
var target: Node2D = null
var anim: AnimatedSprite2D = null

var _attack_cooldown: float = 0.0
var _player_in_range: Node2D = null


func _ready() -> void:
	health = max_health

	# Player must be in "player" group
	target = get_tree().get_first_node_in_group("player")
	if target == null:
		print("Grunt: no player found in group 'player'!")

	anim = $AnimatedSprite2D
	if anim:
		anim.play("idle")


func _physics_process(delta: float) -> void:
	_attack_cooldown -= delta

	if target == null or not is_instance_valid(target):
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Movement toward the player
	var dir: Vector2 = target.global_position - global_position
	if dir.length() > 5.0:
		velocity = dir.normalized() * move_speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	# Attack if player is inside AttackArea and cooldown is ready
	if _player_in_range != null and _attack_cooldown <= 0.0:
		_attack_cooldown = attack_interval
		_attack_target()

	# Animations
	if anim:
		if velocity.length() > 0.0:
			if anim.animation != "run":
				anim.play("run")
		else:
			if anim.animation != "idle":
				anim.play("idle")


func _attack_target() -> void:
	if _player_in_range == null or not is_instance_valid(_player_in_range):
		return

	if _player_in_range.has_method("apply_damage"):
		print("Grunt: attacking player for ", touch_damage, " damage.")
		_player_in_range.apply_damage(touch_damage)
	else:
		print("Grunt: body in range has no apply_damage()!")


func apply_damage(amount: int) -> void:
	health -= amount
	print("Grunt took ", amount, " damage. Health: ", health, "/", max_health)
	if health <= 0:
		die()


func die() -> void:
	print("Grunt died.")
	queue_free()


func _on_attack_area_body_entered(body: Node2D) -> void:
	# Only care about the player entering
	if body.is_in_group("player"):
		print("Grunt: player entered attack area.")
		_player_in_range = body


func _on_attack_area_body_exited(body: Node2D) -> void:
	# If the player left, clear reference
	if body == _player_in_range:
		print("Grunt: player left attack area.")
		_player_in_range = null
