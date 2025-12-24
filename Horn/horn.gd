extends Node3D

signal toggle_visibilty

func _ready():
	pass


func _unhandled_input(event):
	if event.is_action_pressed("show_ui"):
		toggle_visibilty.emit()
