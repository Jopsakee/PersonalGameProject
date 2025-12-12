extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	var level := get_parent()
	if level == null:
		return

	if not level.has_method("on_player_extracted"):
		return

	# Only extract if the level has unlocked it
	if level.extraction_unlocked:
		level.on_player_extracted()
	else:
		print("You can't extract yet! Kill all enemies first.")
