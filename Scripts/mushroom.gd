class_name Mushroom extends Node2D

@export var value: int = 1
var mushroom_mycelium: int = 6
var gnome_in_area = false

func _process(_delta):
	if gnome_in_area:
		if Input.is_action_just_pressed("Mine"):
			GameState.mycelium_collected(1)
			value += 1
		if value == mushroom_mycelium:
			self.queue_free()
		else:
			pass
			
func _on_mining_body_entered(body):
	if body is Gnome:
		gnome_in_area = true

func _on_mining_body_exited(body):
	if body is Gnome:
		gnome_in_area = false
