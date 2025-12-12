extends CanvasLayer

@onready var health_label: Label = $HealthLabel

var player: Node = null


func _ready() -> void:
	# Find the player in the "player" group
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		print("HUD: No player found in group 'player'!")


func _process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		return

	# We expect player to have 'health' and 'max_health' variables
	if "health" in player and "max_health" in player:
		var current_hp: int = player.health
		var max_hp: int = player.max_health
		health_label.text = "HP: %d / %d" % [current_hp, max_hp]
	else:
		health_label.text = "HP: ???"
