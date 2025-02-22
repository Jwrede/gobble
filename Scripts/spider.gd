extends Insect
class_name Spider

@export var min_distance:int = 5
@export var max_distance:int = 25
@export var cost:int = 1

var tamed = false:
	get():
		return tameable_component.tamed
var taming_gnome: Gnome = null:
	get():
		return tameable_component.taming_gnome

var hitflash_frames = 10
var is_dead = false
var is_attacking = false
var team = 10

# References to components.
@export var navigation_agent: NavigationAgent2D
@export var movement_component: Movement
@export var damageable_component: Damageable
@export var attack_component: Attack
@export var knockback_component: Knockback
@export var tameable_component: Tameable

@export var attack_timeout_timer: Timer
@export var sprite_node: AnimatedSprite2D

func _ready():
	randomize()
	_change_wander_target()

func _change_wander_target():
	var random_angle = randf() * TAU
	var random_dist = randf_range(min_distance, max_distance)
	var direction = Vector2(cos(random_angle), sin(random_angle))
	var target = global_position + direction * random_dist
	movement_component.set_target(target)

# Called every frame.
func _physics_process(delta):
	if is_dead:
		return
	if is_attacking:
		attack_component.switch_enemy_if_dead()
	
	if not tamed:
		attack_component.update()
		if not attack_component.enemy in attack_component.enemies_in_range:
			attack_component.set_enemy(null)
		if navigation_agent.is_navigation_finished():
			_change_wander_target()
	else:
		is_attacking = taming_gnome.is_attacking
		if is_attacking:
			attack_component.set_enemy(taming_gnome.attack_component.enemy)
			attack_component.update()
		else:
			movement_component.set_target(taming_gnome.movement_component.target)
			movement_component.move()
		
	knockback_component.update_knockback()
	damageable_component.update(delta)
