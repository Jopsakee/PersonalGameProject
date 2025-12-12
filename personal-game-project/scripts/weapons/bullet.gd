extends Area2D

@export var speed: float = 800.0
@export var lifetime: float = 1.5
@export var damage: int = 10

var direction: Vector2 = Vector2.ZERO
var _time_alive: float = 0.0


func set_direction(dir: Vector2) -> void:
	# Store normalized direction
	direction = dir.normalized()

	# Rotate the bullet so its "forward" (to the right in the texture) matches the direction
	rotation = direction.angle()


func _process(delta: float) -> void:
	if direction != Vector2.ZERO:
		global_position += direction * speed * delta

	_time_alive += delta
	if _time_alive >= lifetime:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		return

	if body.has_method("apply_damage"):
		body.apply_damage(damage)

	queue_free()
