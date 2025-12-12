extends Node2D

@export var speed: float = 800.0

var direction: Vector2 = Vector2.ZERO


func _process(delta: float) -> void:
	if direction != Vector2.ZERO:
		global_position += direction * speed * delta
