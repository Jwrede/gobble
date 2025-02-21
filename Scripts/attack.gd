extends Node
class_name Attack

var enemy: Node = null  # Generic enemy type.
var attack_started: bool = false
var enemy_damaged: bool = false
var enemies_in_range: Array[Node2D] = []
@export var damage_frame: int

@export var enemy_sense_range: Area2D
@export var entity: Node2D
@export var attack_timeout_timer: Timer

func _ready() -> void:
	await get_tree().process_frame 
	attack_timeout_timer.connect("timeout", _on_attack_timeout_timeout)
	enemy_sense_range.connect("body_entered", _on_enemy_sense_range_body_entered)
	enemy_sense_range.connect("body_exited", _on_enemy_sense_range_body_exited)

func set_enemy(e: Node) -> void:
	# Remove outline from current enemy.
	if enemy and enemy.has_node("Damageable") and enemy.damageable_component:
		if entity.has_node("Selection") and entity.selected:
			enemy.damageable_component.outline(false)
	# Set new enemy and apply outline.
	if e and e.has_node("Damageable") and e.damageable_component:
		enemy = e
		if entity.has_node("Selection") and entity.selected:
			enemy.damageable_component.outline(true)

func start_attack():
	if enemy.damageable_component.health > 0:
		attack_started = true
		enemy_damaged = false
		attack_timeout_timer.start(0.5)

func update_attack():
	if enemy == null:
		return
	entity.sprite_node.play("attack")
	# At a specific frame (for example, frame 4) apply damage.
	if entity.sprite_node.frame == damage_frame and not enemy_damaged:
		enemy.damageable_component.apply_damage(10, entity.global_position)
		enemy_damaged = true

func reset_attack():
	attack_started = false

func switch_enemy_if_dead():
	var valid_enemies_in_range = enemies_in_range.filter(func(i): 
		return i and i != enemy and i.damageable_component.health > 0)
	if (enemy == null or enemy.damageable_component.health == 0) and valid_enemies_in_range.size() > 0:
		set_enemy(valid_enemies_in_range[0])

func _on_attack_timeout_timeout() -> void:
	reset_attack()

func _on_enemy_sense_range_body_entered(body: Node2D):
	if body == entity:
		return
	if entity is Gnome and body is Spider:
		if body.taming_gnome != entity:
			enemies_in_range.append(body)
	if entity is Spider and body is Gnome:
		if entity.taming_gnome != body:
			enemies_in_range.append(body)
			
func _on_enemy_sense_range_body_exited(body: Node2D):
	if body in enemies_in_range:
		enemies_in_range.erase(body)
	
