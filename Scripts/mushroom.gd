class_name Mushroom extends Node2D

@export var value: int = 1
@export var sprite: Texture2D
var mushroom_mycelium: int = 6
var gnome_in_area = false

func _ready():
	$MushroomSprite.texture = sprite

func _process(_delta):
	if gnome_in_area:
		if Input.is_action_just_pressed("Mine"):
			print("a")
			GameManager.mycelium_collected(1)
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
