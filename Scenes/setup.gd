extends Node2D

@export var random_spawn_offset: int = 10
@export var n_spawn_gnomes: int = 3
@export var gnome_scene : PackedScene = preload("res://Scenes/gnome.tscn")
@export var gnome_spawn_parent_node : Node
@export var spawn_point : Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in n_spawn_gnomes:
		var gnome_instance = gnome_scene.instantiate()
		gnome_instance.global_position = spawn_point.global_position + \
			Vector2(
				randf_range(-random_spawn_offset,random_spawn_offset), 
				randf_range(-random_spawn_offset,random_spawn_offset)
			)
		gnome_spawn_parent_node.add_child(gnome_instance)
		GameState.gnome_spawned(gnome_instance.gnome)
