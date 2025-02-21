extends Node
class_name Damageable

signal died

@export var health: int = 30
@export var hitflash_frames: int = 10
var hitflash_frame_counter: int = 0

@export var despawn_timer: Timer
@export var entity: Node
@export var sprite: AnimatedSprite2D

func apply_damage(damage_amount: int, from_position: Vector2):
	print(health)
	health = max(health - damage_amount, 0)
	
	if entity.has_node("Knockback"):
		entity.knockback_component.apply_knockback(from_position, 50, entity.global_position)
		sprite.material.set_shader_parameter("hitflash", true)
		sprite.material.set_shader_parameter("use_outline_shader", false)
		
	hitflash_frame_counter = hitflash_frames

func update(delta: float):
	if hitflash_frame_counter > 0:
		hitflash_frame_counter -= 1
		if hitflash_frame_counter <= 1:
			sprite.material.set_shader_parameter("hitflash", false)
			sprite.material.set_shader_parameter("use_outline_shader", true)
			if health == 0:
				_die()

func _die():
	# Play death animation and start despawn timer.
	sprite.play("death")
	despawn_timer.connect("timeout", _on_despawn_timer_timeout)
	despawn_timer.start(10)
	entity.is_dead = true
	emit_signal("died")

func outline(toggle: bool) -> void:
	# Toggle the outline shader parameter on the AnimatedSprite2D if it exists.
	sprite.material.set_shader_parameter("width", toggle)

func _on_despawn_timer_timeout() -> void:
	queue_free()
