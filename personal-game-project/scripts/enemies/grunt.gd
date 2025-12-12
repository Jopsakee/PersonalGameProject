extends CharacterBody2D

@export var move_speed: float = 150.0
@export var max_health: int = 20

var health: int
var target: Node2D = null
var anim: AnimatedSprite2D


func _ready() -> void:
	health = max_health

	# Find the player (player must be in "player" group)
	target = get_tree().get_first_node_in_group("player")

	# Cache the AnimatedSprite2D node
	anim = $AnimatedSprite2D

	# Start with idle animation if it exists
	if anim:
		anim.play("idle")


func _physics_process(_delta: float) -> void:
	if target == null or not is_instance_valid(target):
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var dir: Vector2 = target.global_position - global_position

	if dir.length() > 5.0:
		velocity = dir.normalized() * move_speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	# Animation based on movement
	if anim:
		if velocity.length() > 0.0:
			if anim.animation != "run":
				anim.play("run")
		else:
			if anim.animation != "idle":
				anim.play("idle")


func apply_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		die()


func die() -> void:
	queue_free()
