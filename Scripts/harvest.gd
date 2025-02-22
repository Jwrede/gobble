extends Node
class_name Harvest

var current_resource: HarvestableResource = null
var timeout_ready: bool = true
var resource_in_range: Array[HarvestableResource] = []
var mycelium: int = 0

@export var harvest_range: int = 20
@export var gnome: Node
@export var harvest_timer: Timer
@export var movement_component: Movement

func set_resource(resource: HarvestableResource) -> void:
	# Remove outline from previous resource.
	if current_resource:
		current_resource.outline(false)
	current_resource = resource
	if current_resource:
		current_resource.outline(true)

func harvest():
	if current_resource == null:
		return
	gnome.sprite_node.play("harvest")
	if timeout_ready:
		mycelium += current_resource.harvest()
		timeout_ready = false
		harvest_timer.start(1)

func update():
	switch_resource_if_empty()
	if current_resource and gnome.global_position.distance_to(current_resource.global_position) < harvest_range:
		harvest()
	else:
		movement_component.move()

func switch_resource_if_empty():
	if current_resource == null or current_resource.resources_left <= 0:
		var harvestable_resources = []
		for r in resource_in_range:
			if r.resources_left > 0 and r != current_resource:
				harvestable_resources.append(r)
		if harvestable_resources.size() > 0:
			set_resource(harvestable_resources[0])
			movement_component.set_target(current_resource.global_position)
		else:
			set_resource(null)

func reset_timeout():
	timeout_ready = true

func _on_resource_range_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent is HarvestableResource:
		resource_in_range.append(parent)

func _on_resource_range_area_exited(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent is HarvestableResource:
		resource_in_range.erase(parent)

func _on_harvest_timeout_timeout() -> void:
	timeout_ready = true
