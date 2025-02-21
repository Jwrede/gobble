extends Node
class_name Knockback

# Current knockback force vector.
var knockback_vector: Vector2 = Vector2.ZERO
# Friction (damping) factor – values between 0 and 1.
@export var friction: float = 0.9

@export var entity: Node2D

# Call this function to add knockback force from a given position.
# 'from_position' is the source of the knockback (e.g. the attacker’s position).
# 'strength' is the magnitude of the force.
# 'entity_position' is the current global position of the entity receiving knockback.
func apply_knockback(from_position: Vector2, strength: float, entity_position: Vector2) -> void:
	var direction = (entity_position - from_position).normalized()
	knockback_vector += direction * strength

# Call this each frame to get the current knockback force.
# This method returns the knockback vector and then dampens it.
func update_knockback():
	knockback_vector *= friction
	entity.velocity = knockback_vector
	entity.move_and_slide()
	
