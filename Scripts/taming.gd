extends Node
class_name Taming

var insects_in_range: Array[Insect] = []
var tamed_insects: Array[Insect] = []
var tame_timeout: int
@export var gnome: Node
@export var tame_timer: Timer

func _ready() -> void:
	await get_tree().process_frame 
	tame_timer.connect("timeout", _on_tame_timeout_timeout)
	tame_timer.wait_time = tame_timeout
	tame_timer.start()

func tame_insects() -> void:
	for i in insects_in_range:
		if i.cost <= gnome.mycelium:
			gnome.mycelium -= i.cost
			i.tame(gnome)
			tamed_insects.append(i)

func _on_tame_range_body_entered(body: Node2D) -> void:
	if body is Insect:
		insects_in_range.append(body)

func _on_tame_range_body_exited(body: Node2D) -> void:
	if body is Insect:
		insects_in_range.erase(body)

func _on_tame_timeout_timeout() -> void:
	for i in tamed_insects.duplicate():
		if i.cost <= gnome.mycelium:
			gnome.mycelium -= i.cost
		else:
			i.remove_tame()
			tamed_insects.erase(i)
