extends Node2D 

signal mycelium_changed
var total_mycelium: int = 0
@export var n_spawn_gnomes: int = 3
@export var gnome_spawn_parent_node : Node
@export var gnome_scene : PackedScene

func mycelium_collected(value: int):
	total_mycelium += 1
	emit_signal("mycelium_changed", total_mycelium)

func mycelium_expended(value: int):
	total_mycelium -= 1
	emit_signal("mycelium_changed", total_mycelium)
