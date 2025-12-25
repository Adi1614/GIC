extends CharacterBody3D


const BASE_SPEED = 5.0
const SPRINT_SPEED_MULTIPLIER = 2.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _last_step_location := Vector3.ZERO
var is_crouching = false

@onready var UI_horn = $Camera3D/Horn/HornPlayer/Control
@onready var horn = $Camera3D/Horn
@onready var _mouse_sensitivity := 0.15 / (get_viewport().get_visible_rect().size.x/1152.0)
@onready var _cam := $Camera3D
@onready var _step_sound: AudioStreamPlayer = $StepSound
@onready var vision_target = $VisionTarget
@onready var collider = $CollisionShape3D
@onready var stand_check = $StandCheck
@onready var text_player = $TextPlayer


@export var crouch_height = 1
@export var stand_height = 2
@export var stand_eye_y = 1.4
@export var crouch_eye_y = 0.4

func _ready():
	UI_horn.hide()
	horn.toggle_visibilty.connect(_toggle_visibility)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_last_step_location = Vector3(global_position.x, 0.0, global_position.z)
	

func _toggle_visibility():
	UI_horn.visible = not UI_horn.visible
	if UI_horn.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _crouch():
	if Input.is_action_pressed("crouch"):
		is_crouching = true
		
		if is_crouching:
			var shape := collider.shape as CapsuleShape3D
			shape.height = crouch_height
			vision_target.position.y = crouch_eye_y
		
	else:
		_try_stand()

func _try_stand() -> void:
	if not is_crouching:
		return

	if stand_check.is_colliding():
		# Something above head (table, ceiling)
		return

	is_crouching = false

	var shape := collider.shape as CapsuleShape3D
	shape.height = stand_height

	vision_target.position.y = stand_eye_y

func _physics_process(delta):
	# Handle tap tap tap
	var xz_position := Vector3(global_position.x, 0.0, global_position.z)
	if _last_step_location.distance_to(xz_position) > 2.0:
		_last_step_location = xz_position
		_step_sound.play()
	
	# Add the _gravity.
	if not is_on_floor():
		velocity.y -= _gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Handle sprinting
	var speed_multiplier := SPRINT_SPEED_MULTIPLIER if Input.is_action_pressed("sprint") else 1.0
	
	# Handle Crouch
	_crouch()
	

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * BASE_SPEED * speed_multiplier
		velocity.z = direction.z * BASE_SPEED * speed_multiplier
	else:
		velocity.x = move_toward(velocity.x, 0, BASE_SPEED)
		velocity.z = move_toward(velocity.z, 0, BASE_SPEED)

	move_and_slide()


func _input(event):
	if get_tree().paused:
		return

	if event is InputEventMouseMotion and not UI_horn.visible:
		rotation_degrees.y += event.relative.x * -_mouse_sensitivity
		_cam.rotation_degrees.x += event.relative.y * -_mouse_sensitivity
		_cam.rotation_degrees.x = clamp(_cam.rotation_degrees.x, -90, 90)
