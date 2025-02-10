extends Node2D

@onready var gnome : Gnome = $Gnome

func _on_player_body_selected_toggle(toggle) -> void:
	$Waypoint.visible = toggle


func _on_player_body_waypoint_changed(target) -> void:
	$Waypoint.global_position = target
