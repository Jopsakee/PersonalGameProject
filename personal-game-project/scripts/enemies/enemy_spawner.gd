extends Node2D

@export var enemy_scene: PackedScene          # e.g. grunt.tscn
@export var spawn_count: int = 10             # total enemies to spawn
@export var spawn_interval: float = 1.5       # seconds between spawns
@export var max_alive: int = 5                # max enemies alive at once

var _spawned: int = 0
var _timer: float = 0.0
var _spawn_points: Array[Node2D] = []


func _ready() -> void:
	randomize()
	_timer = spawn_interval

	_spawn_points.clear()
	for child in get_children():
		if child is Node2D:
			_spawn_points.append(child)

	if _spawn_points.is_empty():
		print("EnemySpawner: No spawn points found as children!")


func _process(delta: float) -> void:
	if enemy_scene == null:
		return

	# Stop if we've spawned enough
	if _spawned >= spawn_count:
		return

	# Limit how many are alive at once (uses 'enemy' group)
	var alive: int = get_tree().get_nodes_in_group("enemy").size()
	if alive >= max_alive:
		return

	# Can't spawn if we have no valid points
	if _spawn_points.is_empty():
		return

	_timer -= delta
	if _timer <= 0.0:
		_timer = spawn_interval
		_spawn_enemy()


func _spawn_enemy() -> void:
	var enemy: Node2D = enemy_scene.instantiate()

	# Pick a random spawn point
	var index: int = randi_range(0, _spawn_points.size() - 1)
	var point: Node2D = _spawn_points[index]

	enemy.global_position = point.global_position

	# Add to same parent as spawner (the room)
	get_parent().add_child(enemy)

	_spawned += 1


func all_spawned() -> bool:
	return _spawned >= spawn_count


func get_total_to_spawn() -> int:
	return spawn_count


func get_spawned_count() -> int:
	return _spawned
