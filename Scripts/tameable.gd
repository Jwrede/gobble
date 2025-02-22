extends Node
class_name Tameable

# When a creature isn’t tamed, it uses the default team.
@export var default_team: int = 10
# The collision mask bit index we disable when tamed.
@export var collision_mask_index: int = 7

# Taming state and a reference to the taming gnome.
var tamed: bool = false
var taming_gnome: Node = null
@export var entity: Node2D

func tame(gnome: Node) -> void:
	# Disable the collision bit to prevent unwanted collisions.
	entity.collision_mask = disable_bit(entity.collision_mask, collision_mask_index)
	tamed = true
	taming_gnome = gnome
	# Set the entity’s team to match the gnome’s team.
	entity.team = gnome.team

func remove_tame() -> void:
	var entity = get_parent()
	tamed = false
	taming_gnome = null
	# Reset team back to the default.
	entity.team = default_team

func disable_bit(mask: int, index: int) -> int:
	return mask & ~(1 << index)
