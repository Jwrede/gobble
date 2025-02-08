extends Node


var total_mycelium: int = 0


func mycelium_collected(value: int):
	total_mycelium += 1
	CollectMycelium.emit_signal("mycelium_collected", total_mycelium)

func mycelium_expended(value: int):
	total_mycelium -= 1
	CollectMycelium.emit_signal("mycelium_collected", total_mycelium)
