extends Control

@onready var label = $Label

func _ready():
	CollectMycelium.connect("mycelium_collected", on_event_mycelium_collected)
	

func on_event_mycelium_collected(value: int) -> void:
	label.text = str(value)
	
