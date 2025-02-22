extends Node
class_name Movement

signal waypoint_changed

@export var entity: Node2D
@export var speed: float = 50.0

@export var sprite: AnimatedSprite2D
@export var navigation_agent: NavigationAgent2D
@export var flipped_sprite: bool = false

var target = Vector2.ZERO:
	get():
		return navigation_agent.target_position
	set(value):
		navigation_agent.target_position = value

var facing = true:
	set(value):
		facing = not value if flipped_sprite else value
		sprite.flip_h = facing

func set_target(_target):
	target = _target
	emit_signal("waypoint_changed", _target)

func move():
	var base_velocity: Vector2 = Vector2.ZERO
	
	if navigation_agent.is_navigation_finished():
		sprite.play("idle")
	else:
		var target_position = navigation_agent.get_next_path_position()
		var direction = entity.global_position.direction_to(target_position).normalized()
		base_velocity = direction * speed
		facing = direction.x < 0
		sprite.play("run")
	
	entity.velocity = base_velocity
	entity.move_and_slide()
