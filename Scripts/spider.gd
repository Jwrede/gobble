class_name Spider extends Insect

var tamed = false
@export var speed = 20
@export var limit = 5.0
@export var min_distance = 5
@export var max_distance = 25
@export var cost = 1
@export var health = 30
var knockback_vector: Vector2 = Vector2.ZERO
var knockback_strength: float = 50  # Adjust for stronger knockback
var friction: float = 0.9  # Controls how fast the knockback fades
var hitflash_frames = 10
var hitflash_frame_counter = 0
var is_dead = false

var gnomes_in_range : Array[Gnome] = []
var taming_gnome : Gnome = null

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

func outline(toggle: bool):
	$AnimatedSprite2D.material.set_shader_parameter("width", toggle)
	
func _physics_process(delta):
	if is_dead:
		return
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

	velocity += knockback_vector
	knockback_vector *= friction  # Reduce knockback over time
	
	facing = velocity.x > 0
	move_and_slide()
	
	if hitflash_frame_counter > 0:
		hitflash_frame_counter -= 1
		if hitflash_frame_counter == 0:
			$AnimatedSprite2D.material.set_shader_parameter("hitflash", false)
			$AnimatedSprite2D.material.set_shader_parameter("use_outline_shader", true)
			if health == 0:
				_death()

func damage(damage, from_position):
	health = max(health-damage, 0)
	knockback_vector = (global_position - from_position).normalized() * knockback_strength
	$AnimatedSprite2D.material.set_shader_parameter("hitflash", true)
	$AnimatedSprite2D.material.set_shader_parameter("use_outline_shader", false)
	hitflash_frame_counter = hitflash_frames

func _death():
	$AnimatedSprite2D.play("death")
	$DespawnTimer.start(10)
	is_dead = true

func tame(gnome):
	collision_mask = disable_bit(collision_mask, 7)
	tamed = true
	taming_gnome = gnome

func remove_tame():
	tamed = false
	taming_gnome = null

func disable_bit(mask: int, index: int) -> int:
	return mask & ~(1 << index)


func _on_despawn_timer_timeout() -> void:
	queue_free()
