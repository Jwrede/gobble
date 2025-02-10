extends Node2D 

var gnomes : Array[Gnome] = []

func gnome_spawned(gnome: Gnome):
	gnomes.append(gnome)
