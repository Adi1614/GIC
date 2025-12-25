extends Node3D

@onready var camera: Camera3D = $Camera3D
@onready var menu_ui: Control = $Control

@onready var play_button: Button = $Control/PlayButton
@onready var settings_button: Button = $Control/SettingsButton
@onready var exit_button: Button = $Control/ExitButton

@export var sensitivity := 0.01
@export var smoothing := 10.0

@export var settings_scene: PackedScene   # assign Settings.tscn in Inspector
@export var level_1_scene: PackedScene

var look_velocity := Vector2.ZERO
var settings_instance: Node = null
var camera_input_enabled := true

func _ready() -> void:
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
	if not level_1_scene:
		push_error("Level 1 scene not assigned!")
		return

	get_tree().change_scene_to_packed(level_1_scene)

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
