extends Node2D


func _on_player_body_selected_toggle(toggle) -> void:
	$Waypoint.visible = toggle


func _on_player_body_waypoint_changed(target) -> void:
	$Waypoint.global_position = target
