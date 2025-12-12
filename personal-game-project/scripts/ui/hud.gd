extends CanvasLayer

@onready var enemy_status_label: Label = $EnemyStatusLabel
@onready var name_label: Label = $PlayerFrame/NameLabel
@onready var health_bar: ProgressBar = $PlayerFrame/HealthBar

var player: Node = null
var level: Node = null


func _ready() -> void:
	# Find the player via group
	player = get_tree().get_first_node_in_group("player")

	# Level controller is on the current scene root
	level = get_tree().current_scene

	# Set name label once (optional)
	name_label.text = "Plague Doctor"


func _process(delta: float) -> void:
	_update_health()
	_update_enemy_status()


func _update_health() -> void:
	if player == null or not is_instance_valid(player):
		return

	# Ensure bar max matches player max health
	if "max_health" in player:
		health_bar.max_value = player.max_health

	if "health" in player:
		health_bar.value = clamp(player.health, 0, int(health_bar.max_value))


func _update_enemy_status() -> void:
	if level == null or not is_instance_valid(level):
		return

	if level.has_method("get_enemies_remaining") and level.has_method("is_extraction_unlocked"):
		var remaining: int = level.get_enemies_remaining()
		var unlocked: bool = level.is_extraction_unlocked()

		if unlocked:
			enemy_status_label.text = "Extraction available! Find the stairs to return to the hub."
		else:
			enemy_status_label.text = "Enemies remaining: %d" % remaining
	else:
		enemy_status_label.text = ""
