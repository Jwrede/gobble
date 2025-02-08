class_name Player extends CharacterBody2D

signal selected_toggle
signal waypoint_changed

const SPEED = 700.0
const JUMP_VELOCITY = -400.0
const ran = 10
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

func selected_visuals(toggle: bool):
	$AnimatedSprite2D.material.set_shader_parameter("width", toggle)
	emit_signal("selected_toggle", toggle)
	
func _input(event):
	# Use is_action_pressed to only accept single taps as input instead of mouse drags.
	if event.is_action_pressed(&"right_click") and selected:
		var target = get_global_mouse_position() + Vector2(randf_range(-ran, ran), randf_range(-ran, ran))
		$NavigationAgent2D.target_position = target
		emit_signal("waypoint_changed", target)

func _physics_process(_delta: float) -> void:
	if not $NavigationAgent2D.is_navigation_finished():
		var direction = global_position.direction_to($NavigationAgent2D.get_next_path_position()).normalized()
		
		velocity = direction * 60
		facing = direction.x < 0
		$AnimatedSprite2D.play("run")
		move_and_slide()
	else:
		velocity = Vector2(0,0)
		$AnimatedSprite2D.play("idle")
	queue_redraw() 
