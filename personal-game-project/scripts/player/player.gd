extends CharacterBody2D

@export var move_speed: float = 250.0

@export var bullet_scene: PackedScene
@export var fire_rate: float = 6.0 # bullets per second

@export var max_health: int = 100
@export var shoot_anim_duration: float = 0.15   # how long we stay in the 'shoot' anim
var health: int = 0

var _fire_cooldown: float = 0.0
var _facing: String = "down"  # "down", "up", "left", "right"
var _is_dead: bool = false
var _is_hurt: bool = false
var _shoot_timer: float = 0.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	health = max_health
	_play_idle()


func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	_shoot_timer = max(_shoot_timer - delta, 0.0)

	_handle_movement()
	_handle_shooting(delta)
	_update_animation()


func _handle_movement() -> void:
	var input_vector: Vector2 = Vector2.ZERO

	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	if input_vector.length() > 0.0:
		input_vector = input_vector.normalized()
		velocity = input_vector * move_speed

		# Decide which way we're facing
		if abs(input_vector.x) > abs(input_vector.y):
			_facing = "right" if input_vector.x > 0.0 else "left"
		else:
			_facing = "down" if input_vector.y > 0.0 else "up"
	else:
		velocity = Vector2.ZERO

	move_and_slide()


func _handle_shooting(delta: float) -> void:
	_fire_cooldown -= delta

	if Input.is_action_pressed("shoot") and _fire_cooldown <= 0.0:
		_fire_cooldown = 1.0 / fire_rate
		_spawn_bullet()

		# trigger shoot animation
		_shoot_timer = shoot_anim_duration


func _spawn_bullet() -> void:
	if bullet_scene == null:
		return

	var bullet: Area2D = bullet_scene.instantiate()

	# Direction from player to mouse
	var dir: Vector2 = (get_global_mouse_position() - global_position).normalized()

	# Spawn slightly in front of the player
	bullet.global_position = global_position + dir * 10.0

	if bullet.has_method("set_direction"):
		bullet.set_direction(dir)

	get_parent().add_child(bullet)


func _update_animation() -> void:
	# If we're in the shoot window, show the shoot animation
	if _shoot_timer > 0.0:
		_play_shoot()
		return

	# Otherwise idle or run
	if velocity.length() == 0.0:
		_play_idle()
	else:
		_play_run()


func _play_idle() -> void:
	# Single idle animation
	anim.flip_h = (_facing == "right")  # optional flip for idle
	if anim.animation != "idle":
		anim.play("idle")


func _play_run() -> void:
	match _facing:
		"down":
			anim.flip_h = false
			if anim.animation != "run_down":
				anim.play("run_down")
		"up":
			anim.flip_h = false
			if anim.animation != "run_up":
				anim.play("run_up")
		"left":
			anim.flip_h = false  # original side run faces left
			if anim.animation != "run_side":
				anim.play("run_side")
		"right":
			anim.flip_h = true   # mirror the left run to face right
			if anim.animation != "run_side":
				anim.play("run_side")


func _play_shoot() -> void:
	anim.flip_h = (_facing == "right")
	if anim.animation != "shoot":
		anim.play("shoot")


func apply_damage(amount: int) -> void:
	if _is_dead:
		return

	health -= amount
	print("Player took ", amount, " damage. Health: ", health, "/", max_health)

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
	for i in range(6):
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

	anim.flip_h = false  # avoid mirrored death
	anim.modulate = Color(1, 1, 1, 1)  # reset opacity if we died while blinking
	anim.play("death")

	_wait_and_reload()


func _wait_and_reload() -> void:
	await anim.animation_finished
	get_tree().reload_current_scene()
