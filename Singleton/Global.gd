extends Node

signal EnemyStun
signal LiftObj
signal EnemyCall



func _get_horn_state(state):
	if state == "":
		emit_signal("EnemyCall")
	else:
		emit_signal(state)
