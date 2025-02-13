class_name Gnome extends CharacterBody2D

signal selected_toggle
signal waypoint_changed

@export var SPEED = 50.0
@export var time_timeout = 1

var random_waypoint_offset = 0
var mycelium : int = 0
var harvest_timeout_ready = true

var insects_in_range : Array[Insect] = []
var resource_in_range : Array[HarvestableResource]
var tamed_insects : Array[Insect] = []


var resource_to_harvest : HarvestableResource = null:
	set(r):
		if resource_to_harvest != null:
			resource_to_harvest.outline(false)
		if r != null:
			r.outline(true)
		resource_to_harvest = r

var enemy_to_attack : Insect = null:
	set(e):
		if enemy_to_attack != null:
			enemy_to_attack.outline(false)
		if e != null:
			e.outline(true)
		enemy_to_attack = e

var is_harvesting = false
var is_attacking = false
var attack_started = false

@onready var sprite_node : AnimatedSprite2D = $AnimatedSprite2D
@onready var tame_timout_node : Timer = $TameTimeout
@onready var harvest_timout_node : Timer = $HarvestTimeout
@onready var navigation_agent_node : NavigationAgent2D = $NavigationAgent2D

var selected = false:
	get:
		return selected
	set(v):
		if v != selected:
			selected = v
			selected_visuals(v)

var facing = false:
	get:
		return facing
	set(value):
		if value != facing:
			facing = value
			sprite_node.flip_h = facing

func _ready() -> void:
	tame_timout_node.wait_time = time_timeout
	tame_timout_node.start()

func selected_visuals(toggle: bool):
	sprite_node.material.set_shader_parameter("width", toggle)
	emit_signal("selected_toggle", toggle)
	if resource_to_harvest != null:
		resource_to_harvest.outline(toggle)
	
func _input(event):
	# Use is_action_pressed to only accept single taps as input instead of mouse drags.
	if not selected:
		return
	if event.is_action_pressed(&"right_click"):
		var target = get_global_mouse_position() + \
		Vector2(
			randf_range(-random_waypoint_offset, random_waypoint_offset), 
			randf_range(-random_waypoint_offset, random_waypoint_offset)
		)
		_change_waypoint(target)
		var results = _get_clicked_objects()
		_handle_resource_clicked(results)
		_handle_enemy_clicked(results)
	if event.is_action_pressed("Tame") and mycelium > 0:
		for i in insects_in_range:
			_tame_insect(i)

func _get_clicked_objects():
	# Perform the physics query
	var mouse_pos := get_global_mouse_position()

	var space := get_world_2d().direct_space_state
	var params := PhysicsPointQueryParameters2D.new()
	params.position = mouse_pos
	params.collide_with_areas = true
	params.collide_with_bodies = true
	# Adjust collision_mask to match target nodes' layers
	params.collision_mask = 1

	return space.intersect_point(params).map(func(p): return p.collider)

func _handle_resource_clicked(results):
	# Process results
	results = results.map(func(n): return n.get_parent())
	results = results.filter(func(n): return n is HarvestableResource)
	if len(results) == 0:
		resource_to_harvest = null
		is_harvesting = false
	for result in results:
		resource_to_harvest = result
		is_harvesting = true
		break
			
func _handle_enemy_clicked(results):
	# Process results
	results = results.filter(func(n): return n is Insect)
	if len(results) == 0:
		enemy_to_attack = null
		is_attacking = false
	for result in results:
		enemy_to_attack = result
		is_attacking = true
		break

func _tame_insect(insect: Insect):
	if insect.cost <= mycelium:
		mycelium -= insect.cost
		insect.tame(self)
		tamed_insects.append(insect)
	
func _change_waypoint(target):
	navigation_agent_node.target_position = target
	emit_signal("waypoint_changed", target)
	
func _physics_process(_delta: float) -> void:
	if is_harvesting:
		_check_if_resource_empty()
	if is_attacking:
		_change_waypoint(enemy_to_attack.global_position)
		if not attack_started and \
			global_position.distance_to(enemy_to_attack.global_position) < 10:
			attack_started = true
			$AttackTimeout.start(1)
	if is_attacking and attack_started:
		sprite_node.play("attack")
	elif is_harvesting and \
		resource_to_harvest != null and \
		global_position.distance_to(resource_to_harvest.global_position) < 20:
		_harvest()
	elif not navigation_agent_node.is_navigation_finished():
		var direction = global_position.direction_to(
			navigation_agent_node.get_next_path_position()
		).normalized()
		
		velocity = direction * SPEED
		facing = direction.x < 0
		sprite_node.play("run")
		move_and_slide()
	else:
		velocity = Vector2(0,0)
		sprite_node.play("idle")
	queue_redraw() 

func _check_if_resource_empty():
	if resource_to_harvest == null or resource_to_harvest.resources_left <= 0:
		var harvestable_resources = resource_in_range.filter(func(r): return r.resources_left)
		if len(harvestable_resources) > 0:
			for r in harvestable_resources:
				if r != resource_to_harvest:
					resource_to_harvest = r
					break
			_change_waypoint(resource_to_harvest.global_position)
		else:
			resource_to_harvest = null

func _harvest():	
	sprite_node.play("harvest")
	if harvest_timeout_ready:
		mycelium += resource_to_harvest.harvest()
		harvest_timeout_ready = false
		harvest_timout_node.start(1)

func _on_tame_timeout_timeout() -> void:
	for i in tamed_insects:
		if i.cost <= mycelium:
			mycelium -= i.cost
		else:
			i.remove_tame()
			tamed_insects.erase(i)


func _on_harvest_timeout_timeout() -> void:
	harvest_timeout_ready = true

func _on_tame_range_body_entered(body: Node2D) -> void:
	if body is Insect:
		insects_in_range.append(body)


func _on_tame_range_body_exited(body: Node2D) -> void:
	if body is Insect:
		insects_in_range.erase(body)


func _on_resource_range_area_entered(area: Area2D) -> void:
	if area.get_parent() is HarvestableResource:
		resource_in_range.append(area.get_parent())


func _on_resource_range_area_exited(area: Area2D) -> void:
	if area.get_parent() is HarvestableResource:
		resource_in_range.erase(area.get_parent())


func _on_attack_timeout_timeout() -> void:
	attack_started = false
