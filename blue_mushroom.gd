class_name mushroom extends Node2D

@export var value: int = 1
var mushroom_mycelium: int = 6
var player_in_area = false


func _process(delta):
	if player_in_area:
		if Input.is_action_just_pressed("Mine"):
			GameController.mycelium_collected(value)
			value += 1
		if value == mushroom_mycelium:
			self.queue_free()
		else:
			pass
			
func _on_mining_body_entered(body):
	if body is Player:
		player_in_area = true

func _on_mining_body_exited(body):
	if body is Player:
		player_in_area = false
