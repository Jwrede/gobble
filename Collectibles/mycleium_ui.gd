extends Control

@onready var label = $Label

func _ready():
	GameManager.connect("mycelium_changed", on_event_mycelium_changed)
	
func on_event_mycelium_changed(value: int) -> void:
	label.text = str(value)
	
