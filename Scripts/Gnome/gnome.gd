extends CharacterBody2D
class_name Gnome

var random_waypoint_offset = 0


# We no longer use these variables directly—components now manage them.
var is_harvesting = false
var is_attacking = false
var is_dead = false
var team: int

@onready var sprite_node: AnimatedSprite2D = $AnimatedSprite2D
@onready var tame_timout_node: Timer = $TameTimeout
@onready var harvest_timout_node: Timer = $HarvestTimeout
@onready var attack_timeout_timer: Timer = $AttackTimeout
@onready var navigation_agent_node: NavigationAgent2D = $NavigationAgent2D

# Component variables.
@export var movement_component: Movement
@export var harvest_component: Harvest
@export var attack_component: Attack
@export var taming_component: Taming
@export var selection_component: Selection
@export var damageable_component: Damageable 
@export var knockback_component: Knockback 
@export var mycelium: int:
	get():
		return harvest_component.mycelium if harvest_component else 0
	set(value):
		if harvest_component:
			harvest_component.mycelium = value
@onready var selected: bool = false:
	get():
		return selection_component.selected if selection_component else false
	set(value):
		if selection_component:
			selection_component.selected = value

func _input(event):
	if not selected:
		return
	if event.is_action_pressed("right_click"):
		var target = get_global_mouse_position() + Vector2(
			randf_range(-random_waypoint_offset, random_waypoint_offset),
			randf_range(-random_waypoint_offset, random_waypoint_offset)
		)
		movement_component.set_target(target)
		var results = _get_clicked_objects()
		_handle_resource_clicked(results)
		_handle_enemy_clicked(results)
	if event.is_action_pressed("Tame") and mycelium > 0:
		taming_component.tame_insects()

func _get_clicked_objects():
	var mouse_pos = get_global_mouse_position()
	var space = get_world_2d().direct_space_state
	var params = PhysicsPointQueryParameters2D.new()
	params.position = mouse_pos
	params.collide_with_areas = true
	params.collide_with_bodies = true
	params.collision_mask = 1
	return space.intersect_point(params).map(func(p): return p.collider)

func _handle_resource_clicked(results):
	results = results.map(func(n): return n.get_parent())
	results = results.filter(func(n): return n is HarvestableResource)
	if results.size() == 0:
		is_harvesting = false
		harvest_component.set_resource(null)
	else:
		harvest_component.set_resource(results[0])
		is_harvesting = true
			
func _handle_enemy_clicked(results):
	results = results.filter(func(n): return n is Insect and n.team != team)
	if results.size() == 0:
		is_attacking = false
		attack_component.set_enemy(null)
	else:
		attack_component.set_enemy(results[0])
		is_attacking = true

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if is_attacking:
		attack_component.update()
	elif is_harvesting:
		harvest_component.update()
	elif not navigation_agent_node.is_navigation_finished():
		movement_component.move()
	else:
		velocity = Vector2.ZERO
		sprite_node.play("idle")
	if knockback_component:
		knockback_component.update_knockback()
	if damageable_component:
		damageable_component.update(delta)
	queue_redraw()

func _on_damageable_died() -> void:
	selected = false
