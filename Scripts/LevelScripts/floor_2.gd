extends Node3D

@onready var player = $Player
@onready var light_1 = $OmniLight3D
@onready var light_2 = $OmniLight3D2
@onready var light_3 = $OmniLight3D3
@onready var exitlight = $Exitlight
@onready var door = $Door/CollisionShape3D
@onready var door_swing = $Door_swing
@onready var UI_sfx = $Player/UIsfx

var machine1 = false
var machine2 = false
var machine3 = false

var mach1_area = false
var mach2_area = false
var mach3_area = false

var exit_door_area = false

var level_complete_partial = false
var level_complete = false

# Called when the node enters the scene tree for the first time.
func _ready():
	AudioManager.play_music_level()
	Global.Machine.connect(_machine_complete)
	Global.OpenDoor.connect(_open_door)
	
func _open_door():
	if exit_door_area and level_complete_partial:
		door.disabled = true
		level_complete = true

func _process(delta):
	if level_complete and exit_door_area:
		door_swing.rotation_degrees.y -= move_toward(0, 90, 1)
		door_swing.rotation_degrees.y =clamp(door_swing.rotation_degrees.y, -180.0, -90.0)

	if machine1 and machine2 and machine3 and not level_complete_partial:
		level_complete_partial = true
		_level_complete_indication()

func _level_complete_indication():
	exitlight.light_color = Color(0.0, 0.663, 0.0, 1.0)

func _machine_complete(id : int):
	print(id)
	match id:
		1:
			if mach1_area == true:
				UI_sfx.play()
				machine1 = true
				light_1.light_color = Color(0.0, 0.663, 0.0, 1.0)
		2:
			if mach2_area == true:
				UI_sfx.play()
				machine2 = true
				light_2.light_color = Color(0.0, 0.663, 0.0, 1.0)
		3:
			if mach3_area == true:
				UI_sfx.play()
				machine3 = true
				light_3.light_color = Color(0.0, 0.663, 0.0, 1.0)

func _on_area_3d_body_entered(body):
	if body.name == "Player" and not machine1:
		mach1_area = true
		Global.ShowInteractUI(1)

func _on_area_3d_body_exited(body):
	if body.name == "Player":
		mach1_area = false
		Global.HideUI()

func _on_machine_2_body_entered(body):
	print(body)
	print(machine2)
	if body.name == "Player" and not machine2:
		mach2_area = true
		Global.ShowInteractUI(1)

func _on_machine_2_body_exited(body):
	if body.name == "Player":
		mach2_area = false
		Global.HideUI()

func _on_machine_3_body_entered(body):
	if body.name == "Player" and not machine3:
		mach3_area = true
		Global.ShowInteractUI(1)

func _on_machine_3_body_exited(body):
	if body.name == "Player":
		mach3_area = false
		Global.HideUI()

func _on_note_1_body_entered(body):
	if body.name == "Player" and not player.is_crouching:
		Global.Show_Note(1)

func _on_note_1_body_exited(body):
	if body.name == "Player":
		Global.HideUI()

func _on_note_2_body_entered(body):
	if body.name == "Player" and not player.is_crouching:
		Global.Show_Note(2)

func _on_note_2_body_exited(body):
	if body.name == "Player":
		Global.HideUI()

func _on_note_3_body_entered(body):
	if body.name == "Player" and not player.is_crouching:
		Global.Show_Note(3)

func _on_note_3_body_exited(body):
	if body.name == "Player":
		Global.HideUI()

func _on_exit_door_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		exit_door_area = true
		if not AudioManager.dialogue_player.playing:
			if not level_complete_partial:
				Global.ShowInteractUI(18)
			else:
				Global.ShowInteractUI(6)

func _on_exit_door_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		exit_door_area = false
		Global.HideUI()

func _on_level_inititalte_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		Global.ShowInteractUI(8)

#func _on_level_inititalte_body_exited(body: Node3D) -> void:#needs to be changed to hide ui when audio is done playing instead
	#if body.name == "Player":
		#Global.HideUI()

func _on_exit_area_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		Global.ShowInteractUI(9)

#func _on_exit_area_body_exited(body: Node3D) -> void:#needs to be changed to hide ui when audio is done playing instead
	#if body.name == "Player":
		#Global.HideUI()

func _on_next_level_body_entered(body):
	if body.name == "Player" and level_complete:
		Global.change_scene(
			"res://Scenes/Level/floor_3.tscn",
			"LEVEL 3 - RUN"
		)
