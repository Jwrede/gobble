extends Node
class_name Selection

@export var gnome: Gnome
@export var sprite: AnimatedSprite2D

var selected = false:
	set(value):
		if value and gnome.is_dead:
			pass
		if value != selected:
			selected = value
			toggle_selected(value)
			
signal selected_toggle(toggle:bool)

func toggle_selected(_selected: bool):
	print("A")
	# Update visual state.
	sprite.material.set_shader_parameter("width", _selected)
	emit_signal("selected_toggle", _selected)
	# Also update the outline of the resource if one is set.
	if gnome.harvest_component and gnome.harvest_component.current_resource:
		gnome.harvest_component.current_resource.outline(_selected)
