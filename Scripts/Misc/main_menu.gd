extends Node3D

@onready var camera: Camera3D = $Camera3D
@onready var menu_ui: Control = $Control

@onready var play_button: Button = $Control/PlayButton
@onready var settings_button: Button = $Control/SettingsButton
@onready var exit_button: Button = $Control/ExitButton
@onready var credits = $Control/Credits

@export var sensitivity := 0.01
@export var smoothing := 10.0

@export var settings_scene: PackedScene   # assign Settings.tscn in Inspector
@export var play_scene: PackedScene

var credits_scn = preload("res://Scenes/Level/credits.tscn")


var look_velocity := Vector2.ZERO
var settings_instance: Node = null
var camera_input_enabled := true

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	AudioManager.play_music_level()
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

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

# -------------------------------------------------
# BUTTON CALLBACKS
# -------------------------------------------------

func _on_play_pressed() -> void:
	if not play_scene:
		push_error("Level 1 scene not assigned!")
		return
	Global.reset_game()
	Global.change_scene(
		play_scene.resource_path,
		"EXPERIMENT: TEST 555"
	)

func _on_settings_pressed() -> void:
	if settings_instance:
		return

	camera_input_enabled = false
	look_velocity = Vector2.ZERO

	menu_ui.visible = false

	settings_instance = settings_scene.instantiate()
	add_child(settings_instance)

	# Optional: let settings menu close itself
	if settings_instance.has_signal("closed"):
		settings_instance.closed.connect(_on_settings_closed)

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_settings_closed() -> void:
	if settings_instance:
		settings_instance.queue_free()
		settings_instance = null

	menu_ui.visible = true
	camera_input_enabled = true


func _on_credits_pressed():
	call_deferred("_change_to_credit")

func _change_to_credit():
		Global.change_scene(
			credits_scn.resource_path,
			" "
		)
