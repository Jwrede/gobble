# StateMachine.gd
class_name GnomeStateMachine
extends Node

var states: Dictionary = {}
var current_state: State
var gnome: Gnome

func _init(owner: Gnome) -> void:
	self.gnome = owner

func add_state(state_name: String, state: State) -> void:
	states[state_name] = state
	state.gnome = gnome
	add_child(state)

func transition_to(state_name: String) -> void:
	if current_state:
		current_state.exit()
	current_state = states[state_name]
	current_state.enter()

func physics_update(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func handle_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)

# Base State class
class State extends Node:
	var gnome: Gnome
	func enter(): pass
	func exit(): pass
	func physics_update(_delta: float): pass
	func handle_input(_event: InputEvent): pass

# Concrete States
class IdleState extends State:
	func physics_update(_delta):
		gnome.velocity = Vector2.ZERO
		gnome.sprite_node.play("idle")

class MoveState extends State:
	func physics_update(delta):
		var target = gnome.navigation_agent_node.get_next_path_position()
		var direction = gnome.global_position.direction_to(target).normalized()
		gnome.velocity = direction * gnome.SPEED
		gnome.facing = direction.x < 0
		gnome.sprite_node.play("run")
		gnome.move_and_slide()

class HarvestState extends State:
	func enter():
		gnome.harvest_component.start_harvesting()

	func physics_update(delta):
		if not gnome.harvest_component.current_resource:
			gnome.state_machine.transition_to("Idle")
			return
		
		var distance = gnome.global_position.distance_to(
			gnome.harvest_component.current_resource.global_position
		)
		if distance > 20:
			gnome.state_machine.transition_to("Move")

class AttackState extends State:
	func enter():
		gnome.attack_component.start_attack()

	func physics_update(delta):
		if not gnome.attack_component.current_target:
			gnome.state_machine.transition_to("Idle")
			return
		
		var distance = gnome.global_position.distance_to(
			gnome.attack_component.current_target.global_position
		)
		if distance > 10:
			gnome.state_machine.transition_to("Move")
