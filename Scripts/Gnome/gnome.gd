class_name Gnome extends CharacterBody2D

signal selected_toggle
signal waypoint_changed

@export var SPEED = 50.0
@export var time_timeout = 1
var insects_in_range : Array[Insect] = []
var tamed_insects : Array[Insect] = []
var random_waypoint_offset = 5
var mycelium : int = 10

var selected = false:
	get:
		return selected
	set(v):
		if v != selected:
			selected = v
			selected_visuals(v)

var facing = true:
	get:
		return facing
	set(value):
		if value != facing:
			facing = value
			$AnimatedSprite2D.flip_h = facing

func _ready() -> void:
	$TameTimeout.wait_time = time_timeout
	$TameTimeout.start()

func selected_visuals(toggle: bool):
	$AnimatedSprite2D.material.set_shader_parameter("width", toggle)
	emit_signal("selected_toggle", toggle)
	
func _input(event):
	# Use is_action_pressed to only accept single taps as input instead of mouse drags.
	if event.is_action_pressed(&"right_click") and selected:
		var target = get_global_mouse_position() + \
			Vector2(
				randf_range(-random_waypoint_offset, random_waypoint_offset), 
				randf_range(-random_waypoint_offset, random_waypoint_offset)
			)
		$NavigationAgent2D.target_position = target
		emit_signal("waypoint_changed", target)
	if event.is_action_pressed("Tame") and selected and mycelium > 0:
		for i in insects_in_range:
			if i.cost <= mycelium:
				mycelium -= i.cost
				i.tame(self)
				tamed_insects.append(i)

func _physics_process(_delta: float) -> void:
	if not $NavigationAgent2D.is_navigation_finished():
		var direction = global_position.direction_to($NavigationAgent2D.get_next_path_position()).normalized()
		
		velocity = direction * SPEED
		facing = direction.x < 0
		$AnimatedSprite2D.play("run")
		move_and_slide()
	else:
		velocity = Vector2(0,0)
		$AnimatedSprite2D.play("idle")
	queue_redraw() 


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Insect:
		insects_in_range.append(body)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Insect:
		insects_in_range.erase(body)

func _on_tame_timeout_timeout() -> void:
	for i in tamed_insects:
		if i.cost <= mycelium:
			mycelium -= i.cost
		else:
			i.remove_tame()
			tamed_insects.erase(i)
