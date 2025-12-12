extends Node2D

@export var spawner_path: NodePath = NodePath("EnemySpawner")
@export var next_level_scene: PackedScene    # optional, can be left empty for now

var extraction_unlocked: bool = false
var spawner: Node = null

@onready var extraction_zone: Area2D = $ExtractionZone


func _ready() -> void:
	spawner = get_node_or_null(spawner_path)

	# Hide / disable extraction at start
	if extraction_zone:
		extraction_zone.visible = false
		extraction_zone.monitoring = false


func _process(delta: float) -> void:
	if extraction_unlocked:
		return

	# Check if spawner has finished spawning
	var all_spawned_flag: bool = true

	if spawner and spawner.has_method("all_spawned"):
		all_spawned_flag = spawner.all_spawned()

	if not all_spawned_flag:
		return

	# If no enemies remain, unlock extraction
	var alive: int = get_tree().get_nodes_in_group("enemy").size()
	if alive == 0:
		_unlock_extraction()


func _unlock_extraction() -> void:
	extraction_unlocked = true
	print("Extraction unlocked! Go to the extraction zone.")

	if extraction_zone:
		extraction_zone.visible = true
		extraction_zone.monitoring = true


func on_player_extracted() -> void:
	print("Player extracted!")

	if next_level_scene:
		get_tree().change_scene_to_packed(next_level_scene)
	else:
		# Placeholder: just reload this level for now
		get_tree().reload_current_scene()


# ---------- Helpers for HUD ----------

func get_enemies_remaining() -> int:
	# How many enemies are left total (alive + not yet spawned)
	if spawner == null:
		return 0
	if not (spawner.has_method("get_total_to_spawn") and spawner.has_method("get_spawned_count")):
		return 0

	var total: int = spawner.get_total_to_spawn()
	var spawned: int = spawner.get_spawned_count()
	var alive: int = get_tree().get_nodes_in_group("enemy").size()

	# Enemies killed so far = spawned - alive
	var killed: int = max(spawned - alive, 0)
	var remaining: int = max(total - killed, 0)
	return remaining


func is_extraction_unlocked() -> bool:
	return extraction_unlocked
