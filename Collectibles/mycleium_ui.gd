extends Control

@onready var label = $Label
	
func _process(_delta) -> void:
	label.text = str(GameState.gnomes.map(func(g:Gnome): return str(g.mycelium)))
	
