extends Insect
class_name Spider

@export var min_distance:int = 5
@export var max_distance:int = 25
@export var cost:int = 1

var tamed = false
var taming_gnome: Gnome = null

var hitflash_frames = 10
var is_dead = false
var is_attacking = false

# References to components.
@export var navigation_agent: NavigationAgent2D
@export var movement_component: Movement
@export var damageable_component: Damageable
@export var attack_component: Attack
@export var knockback_component: Knockback

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
	navigation_agent.target_position = target

# Called every frame.
func _physics_process(delta):
	if is_dead:
		return
	if is_attacking:
		attack_component.switch_enemy_if_dead()
	
	if not tamed:
		if is_attacking:
			if global_position.distance_to(attack_component.enemy.global_position) > 20:
				navigation_agent.target_position = attack_component.enemy.global_position
				movement_component.move()
			else:
				if not attack_component.attack_started:
					attack_component.start_attack()
				else:
					attack_component.update_attack()
		elif navigation_agent.is_navigation_finished():
			_change_wander_target()
		else:
			movement_component.move()
	else:
		# If tamed, follow the gnome.
		var gnome_target = taming_gnome.get_child(1).target_position
		navigation_agent.target_position = gnome_target
		movement_component.move()
		
	knockback_component.update_knockback()
	damageable_component.update(delta)

func tame(gnome):
	collision_mask = disable_bit(collision_mask, 7)
	tamed = true
	taming_gnome = gnome

func remove_tame():
	tamed = false
	taming_gnome = null

func disable_bit(mask: int, index: int) -> int:
	return mask & ~(1 << index)


func _on_attack_range_body_entered(body: Node2D) -> void:
	if body is Gnome and body.has_node("Damageable"):
		attack_component.set_enemy(body)
		is_attacking = true


func _on_attack_range_body_exited(body: Node2D) -> void:
	if body is Gnome and body.has_node("Damageable"):
		attack_component.set_enemy(null)
		is_attacking = false
