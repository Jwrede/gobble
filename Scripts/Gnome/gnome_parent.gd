extends Node2D

@onready var gnome : Gnome = $Gnome

func _on_player_body_waypoint_changed(target) -> void:
	$Waypoint.global_position = target

func _on_selection_selected_toggle(toggle: bool) -> void:
	$Waypoint.visible = toggle
