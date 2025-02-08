extends Node2D

@export var spawn_interval : float = 5
@export var insect_scene : PackedScene
@export var insect_spawn_node : Node

func _ready() -> void:
	$Timer.wait_time = spawn_interval
	$Timer.start()

func _on_timer_timeout() -> void:
	spawn_unit()
	
func spawn_unit():
	if insect_scene == null or insect_spawn_node == null:
		return

	var unit = insect_scene.instantiate()
	unit.global_position = $SpawnPoint.global_position
	insect_spawn_node.add_child(unit)  # Add to the parent scene (e.g., the level)
