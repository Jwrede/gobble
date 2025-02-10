extends Control

@onready var label = $Label
	
func _process(_delta) -> void:
	print(GameState.gnomes[0].mycelium)
	label.text = str(GameState.gnomes.map(func(g:Gnome): return str(g.mycelium)))
	
