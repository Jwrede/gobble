extends CharacterBody2D

@export var speed = 20
@export var limit = 5.0
@export var min_distance = 5
@export var max_distance = 25
@export var tamed = false

@onready var player = get_parent().get_parent().get_node("Units/Unit1/PlayerBody")

var mycelium_stack = 0
var end_position = Vector2.ZERO
var player_in_range = false
var facing = true:
	get:
		return facing
	set(value):
		if value != facing:
			facing = value
			$AnimatedSprite2D.flip_h = facing

func _ready():
	randomize()
	_change_direction()

func _change_direction():
	var random_angle = randf() * TAU
	var random_dist = randf_range(min_distance, max_distance)
	var direction = Vector2(cos(random_angle), sin(random_angle))
	end_position = position + direction * random_dist

func _physics_process(delta):
	$AnimatedSprite2D.play("run")
	if not tamed:
		var move_direction = end_position - position
		if move_direction.length() < limit:
			_change_direction()
			move_direction = end_position - position
		velocity = move_direction.normalized() * speed
	else:
		var player_position = player.global_position
		var distance_to_player = global_position.distance_to(player_position)
		if distance_to_player > 1:
			velocity = (player_position - global_position).normalized() * (speed*2)
		else:
			velocity = Vector2.ZERO
	
	facing = velocity.x > 0
	move_and_slide()

func _process(delta):
	if player_in_range:
		if Input.is_action_just_pressed("Tame"):
			mycelium_stack = 1
			GameController.mycelium_expended(1)
			tamed = true
			$tame_timer.start()

func _on_area_2d_body_entered(body):
	if body is Player:
		player_in_range = true

func _on_area_2d_body_exited(body):
	if body is Player:
		player_in_range = false

func _on_tame_timer_timeout():
	if tamed:
		tamed = false
