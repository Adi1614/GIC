extends Node

signal EnemyStun
signal InteractObj
signal EnemyCall
signal Machine(id: int)
signal HideUi
signal ShowUi(id: int)



func _get_horn_state(state):
	match state:
		"EnemyStun":
			emit_signal(state)
			return
		
		"Machine 1":
			emit_signal("Machine", 1)
		
		"Machine 2":
			emit_signal("Machine", 2)
			
		"Machine 3":
			emit_signal("Machine", 3)
			
	
	emit_signal("EnemyCall")
	
	
func ShowInteractUI(id: int):
	emit_signal("ShowUi", id)
	
func HideUI():
	emit_signal("HideUi")
	
