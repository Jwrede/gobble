class_name Insect extends CharacterBody2D

var tamed = false
@export var speed = 20
@export var limit = 5.0
@export var min_distance = 5
@export var max_distance = 25
@export var cost = 1

var gnomes_in_range : Array[Gnome] = []
var taming_gnome : Gnome = null

var mycelium_stack = 0
var end_position = Vector2.ZERO
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
		var gnome_position = taming_gnome.get_child(1).target_position
		var distance_to_gnome = global_position.distance_to(gnome_position)
		if distance_to_gnome > 1:
			velocity = (gnome_position - global_position).normalized() * (speed*2)
		else:
			velocity = Vector2.ZERO
	
	facing = velocity.x > 0
	move_and_slide()

func tame(gnome):
	collision_mask = disable_bit(collision_mask, 7)
	tamed = true
	taming_gnome = gnome

func remove_tame():
	tamed = false
	taming_gnome = null

func disable_bit(mask: int, index: int) -> int:
	return mask & ~(1 << index)
