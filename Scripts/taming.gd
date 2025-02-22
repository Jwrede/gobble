extends Node
class_name Taming

var insects_in_range: Array[Insect] = []
var tamed_insects: Array[Insect] = []
@export var tame_timeout: int
@export var gnome: Node
@export var tame_timer: Timer

func _ready() -> void:
	await get_tree().process_frame 
	tame_timer.connect("timeout", _on_tame_timeout_timeout)
	tame_timer.wait_time = tame_timeout
	tame_timer.start()

func tame_insects() -> void:
	for i in insects_in_range:
		if i.cost <= gnome.mycelium and not i.is_dead:
			gnome.mycelium -= i.cost
			i.tameable_component.tame(gnome)
			tamed_insects.append(i)

func _on_tame_range_body_entered(body: Node2D) -> void:
	if body is Insect:
		insects_in_range.append(body)

func _on_tame_range_body_exited(body: Node2D) -> void:
	if body is Insect:
		insects_in_range.erase(body)

func _on_tame_timeout_timeout() -> void:
	var valid_tamed_insects = tamed_insects.filter(func(i):
		return is_instance_valid(i)
	)
	for i in valid_tamed_insects:
		if i.cost <= gnome.mycelium:
			gnome.mycelium -= i.cost
		else:
			i.remove_tame()
			tamed_insects.erase(i)
