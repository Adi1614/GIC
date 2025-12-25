extends Node3D

@onready var player = $Player
@onready var light_1 = $OmniLight3D
@onready var light_2 = $OmniLight3D2
@onready var light_3 = $OmniLight3D3
@onready var exitlight = $Exitlight

var machine1 = false
var machine2 = false
var machine3 = false

var mach1_area = false
var mach2_area = false
var mach3_area = false

var level_complete = false

# Called when the node enters the scene tree for the first time.
func _ready():
	AudioManager.play_music_level()
	Global.Machine.connect(_machine_complete)

func _process(delta):
	if machine1 and machine2 and machine3 and not level_complete:
		level_complete = true
		_level_complete_indication()

func _level_complete_indication():
	exitlight.light_color = Color(0.0, 0.663, 0.0, 1.0)

func _machine_complete(id : int):
	print(id)
	match id:
		1:
			if mach1_area == true:
				machine1 = true
				light_1.light_color = Color(0.0, 0.663, 0.0, 1.0)
		2:
			print(mach2_area)
			if mach2_area == true:
				machine2 = true
				light_2.light_color = Color(0.0, 0.663, 0.0, 1.0)
		3:
			if mach3_area == true:
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
