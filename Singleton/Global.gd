extends Node

signal EnemyStun
signal InteractObj
signal EnemyCall
signal Machine(id: int)
signal HideUi
signal ShowUi(id: int)
signal ShowNote(id: int)

@export var escape_menu_scene: PackedScene = preload("res://Scenes/UI/escape_menu.tscn")

var player_under_table = false
var enemy_near_table = false


#---------------------Pause Menu-------------------

var pause_menu: CanvasLayer = null
var is_paused := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()

#-------------------------------------------------
#PAUSE CONTROL
#-------------------------------------------------
func toggle_pause() -> void:
	if _is_in_main_menu():
		return

	if is_paused:
		resume_game()
	else:
		pause_game()

func pause_game() -> void:
	if is_paused:
		return

	is_paused = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	pause_menu = escape_menu_scene.instantiate()
	get_tree().current_scene.add_child(pause_menu)

func resume_game() -> void:
	if not is_paused:
		return

	is_paused = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if pause_menu:
		pause_menu.queue_free()
		pause_menu = null

func force_resume() -> void:
	# Used when changing scenes
	is_paused = false
	get_tree().paused = false

	if pause_menu:
		pause_menu.queue_free()
		pause_menu = null

#-------------------------------------------------
#HELPERS
#-------------------------------------------------
func _is_in_main_menu() -> bool:
	return get_tree().current_scene.name == "MainMenu"

#-------------------------------------------------------------



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
	
func Show_Note(id: int):
	emit_signal("ShowNote", id)
	
