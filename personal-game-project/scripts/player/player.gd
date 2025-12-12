extends CharacterBody2D

@export var move_speed: float = 250.0

@export var bullet_scene: PackedScene
@export var fire_rate: float = 6.0 # bullets per second

@export var max_health: int = 100
var health: int = 0

var _fire_cooldown: float = 0.0


func _ready() -> void:
	# Initialize health
	health = max_health


func _physics_process(delta: float) -> void:
	_handle_movement()
	_handle_aiming()
	_handle_shooting(delta)


func _handle_movement() -> void:
	var input_vector: Vector2 = Vector2.ZERO

	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	if input_vector.length() > 0.0:
		input_vector = input_vector.normalized()
		velocity = input_vector * move_speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()


func _handle_aiming() -> void:
	look_at(get_global_mouse_position())


func _handle_shooting(delta: float) -> void:
	_fire_cooldown -= delta

	if Input.is_action_pressed("shoot") and _fire_cooldown <= 0.0:
		_fire_cooldown = 1.0 / fire_rate
		_spawn_bullet()


func _spawn_bullet() -> void:
	if bullet_scene == null:
		return

	var bullet: Area2D = bullet_scene.instantiate()

	# Direction from player to mouse
	var dir: Vector2 = (get_global_mouse_position() - global_position).normalized()

	# Spawn slightly in front of the player so it doesn't collide with them
	bullet.global_position = global_position + dir * 10.0

	if bullet.has_method("set_direction"):
		bullet.set_direction(dir)

	get_parent().add_child(bullet)


func apply_damage(amount: int) -> void:
	health -= amount
	print("Player took ", amount, " damage. Health: ", health, "/", max_health)

	if health <= 0:
		die()


func die() -> void:
	print("Player died. Reloading scene.")
	get_tree().reload_current_scene()
