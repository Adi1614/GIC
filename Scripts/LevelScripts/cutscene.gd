extends Node3D

@onready var camera: Camera3D = $Camera3D
@export var sensitivity := 0.01
@export var smoothing := 10.0

var look_velocity := Vector2.ZERO
var settings_instance: Node = null
var camera_input_enabled := true

# Walkie-talkie cutscene dialogue IDs (ORDER MATTERS)
var cutscene_ids := [11, 12, 13, 14, 15, 16, 17]

var _index := 0
var _waiting_for_audio := false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Small delay so scene fully loads
	Global.HideUi.connect(_on_ui_hidden)
	await get_tree().create_timer(0.5).timeout
	_play_next()


func _input(event: InputEvent) -> void:
	if not camera_input_enabled:
		return

	if event is InputEventMouseMotion:
		look_velocity += event.relative * sensitivity

func _process(delta: float) -> void:
	if not camera_input_enabled:
		return

	look_velocity = look_velocity.lerp(Vector2.ZERO, smoothing * delta)

	camera.rotation_degrees.y -= look_velocity.x
	camera.rotation_degrees.x -= look_velocity.y

	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -70, -50)
	camera.rotation_degrees.y = clamp(camera.rotation_degrees.y, -12, 10)

#-----------Audio Dialogues--------

func _play_next():
	if _index >= cutscene_ids.size():
		_cutscene_finished()
		return

	var id :int= cutscene_ids[_index]
	_index += 1
	_waiting_for_audio = true

	# Show text (AudioManager will react automatically)
	Global.ShowInteractUI(id)

func _on_ui_hidden():
	# Called when AudioManager hides UI after audio finishes
	if _waiting_for_audio:
		_waiting_for_audio = false
		await get_tree().create_timer(1.0).timeout
		_play_next()

func _cutscene_finished():
	# Optional: short silence before transition
	await get_tree().create_timer(0.8).timeout

	# Transition to Level 1
	Global.change_scene(
		"res://Scenes/Level/floor_1.tscn",
		"FLOOR 1 - SOUND"
	)
