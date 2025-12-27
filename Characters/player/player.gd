extends CharacterBody3D


const BASE_SPEED = 3.0
const SPRINT_SPEED_MULTIPLIER = 2.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _last_step_location := Vector3.ZERO
var is_crouching = false
var speed_multiplier = 1.0
var sprinting = false
var enemy_position: Vector3

const FAST_HEART_BEAT = preload("res://Assets/Sounds/Background/fast heart beat.mp3")
const SLOW_HEART_BEAT = preload("res://Assets/Sounds/Background/slow heart beat.wav")



@onready var UI_horn = $Camera3D/Horn/HornPlayer/Control
@onready var horn = $Camera3D/Horn
@onready var _mouse_sensitivity := 0.15 / (get_viewport().get_visible_rect().size.x/1152.0)
@onready var _cam := $Camera3D
@onready var _step_sound: AudioStreamPlayer = $StepSound
@onready var vision_target = $VisionTarget
@onready var collider = $CollisionShape3D
@onready var stand_check = $StandCheck
@onready var text_player = $TextPlayer
@onready var enemy = $"../Enemy"
@onready var heart_beat_player:AudioStreamPlayer = $HeartBeat
@onready var UI_sfx = $UIsfx


# ==================================================
# CAMERA – CORE MOTION
# ==================================================
@export var bob_frequency := 7.5
@export var bob_amplitude := 0.05
@export var sprint_bob_multiplier := 1.5
@export var crouch_bob_multiplier := 0.5

@export var idle_breath_frequency := 1.2
@export var idle_breath_amplitude := 0.02

@export var camera_smoothness := 10.0

@export var sprint_regen_time = 2.6
@export var sprint_max_time = 5.0

# ==================================================
# CAMERA – HORROR LAYERS
# ==================================================
@export var unease_sway_amplitude := 0.015
@export var unease_sway_speed := 0.6

@export var breath_jitter_amplitude := 0.004
@export var breath_jitter_speed := 8.0

@export var stop_inertia_strength := 0.08
@export var stop_inertia_smoothness := 6.0

@export var fear_pulse_strength := 0.01
@export var fear_pulse_decay := 3.5

# ==================================================
# STATE
# ==================================================
var _bob_time := 0.0
var _unease_time := 0.0
var _fear_pulse := 0.0
var _default_cam_y := 0.0
var _camera_offset := Vector3.ZERO
var _last_velocity := Vector3.ZERO
var sprint_time = sprint_max_time

@export var crouch_height = 1
@export var stand_height = 2
@export var stand_eye_y = 1.4
@export var crouch_eye_y = 0.4

func _ready():
	if not Global.got_horn:
		horn.hide()
	UI_horn.hide()
	horn.toggle_visibilty.connect(_toggle_visibility)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Global.PlayerCaught.connect(_play_death)
	vision_target.position.y = stand_eye_y
	_default_cam_y = _cam.position.y
	_last_step_location = Vector3(global_position.x, 0.0, global_position.z)

# ==================================================
# FEAR SYSTEM (CALL FROM EVENTS)
# ==================================================
func trigger_fear(intensity := 1.0):
	_fear_pulse = clamp(_fear_pulse + intensity, 0.0, 1.5)

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

# ==================================================
# CAMERA UPDATE (HORROR CORE)
# ==================================================
func _update_camera_motion(delta):
	var horizontal_speed := Vector2(velocity.x, velocity.z).length()
	var is_moving := horizontal_speed > 0.1 and is_on_floor()

	var target_y := _default_cam_y
	_unease_time += delta

	# Walk / idle bob
	if is_moving:
		_bob_time += delta * bob_frequency * (horizontal_speed / BASE_SPEED)

		var bob_mult := 1.0
		if Input.is_action_pressed("sprint"):
			bob_mult *= sprint_bob_multiplier
		if is_crouching:
			bob_mult *= crouch_bob_multiplier

		target_y += sin(_bob_time) * bob_amplitude * bob_mult
	else:
		_bob_time += delta * idle_breath_frequency
		target_y += sin(_bob_time) * idle_breath_amplitude
		target_y += sin(_unease_time * unease_sway_speed) * unease_sway_amplitude

	# Breathing jitter
	var breath_jitter := sin(_unease_time * breath_jitter_speed) * breath_jitter_amplitude

	# Stop inertia
	var delta_velocity := _last_velocity - velocity
	_camera_offset += Vector3(-delta_velocity.x, 0, -delta_velocity.z) * stop_inertia_strength
	_camera_offset = _camera_offset.lerp(Vector3.ZERO, delta * stop_inertia_smoothness)
	_last_velocity = velocity

	# Fear pulse
	if _fear_pulse > 0.0:
		_camera_offset.y += randf_range(-1, 1) * _fear_pulse * fear_pulse_strength
		_fear_pulse = move_toward(_fear_pulse, 0.0, delta * fear_pulse_decay)

	# Apply
	_cam.position.y = lerp(
		_cam.position.y,
		target_y + breath_jitter + _camera_offset.y,
		delta * camera_smoothness
	)


func _physics_process(delta):
	# Handle tap tap tap
	var xz_position := Vector3(global_position.x, 0.0, global_position.z)
	if _last_step_location.distance_to(xz_position) > 2.0:
		_last_step_location = xz_position
		_step_sound.play()
		
	if enemy.state == enemy.STATES.CHASE:
		if not heart_beat_player.playing:
			heart_beat_player.stream = FAST_HEART_BEAT
			heart_beat_player.play()
	
	elif enemy.state == enemy.STATES.SEARCH:
		if not heart_beat_player.playing:
			heart_beat_player.stream = SLOW_HEART_BEAT
			heart_beat_player.play()
	
	elif enemy.state == enemy.STATES.ROAM:
		heart_beat_player.stop()
	
	# Add the _gravity.
	if not is_on_floor():
		velocity.y -= _gravity * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
	#
	 #Handle sprinting
	
	if Input.is_action_just_released("sprint") and sprinting:
		sprinting = false
		
	if sprint_time > 0.0:
		if Input.is_action_pressed("sprint") and not is_crouching:
			sprinting = true
			sprint_time -= delta
			speed_multiplier = SPRINT_SPEED_MULTIPLIER 
	
	elif sprint_time <= 0.0:
		speed_multiplier = 1.0 
	
	if not sprinting:
		sprint_time = clamp(sprint_time, 0.0, sprint_max_time)
		sprint_time += delta
		speed_multiplier = 1.0
	
	#if Input.is_action_pressed("sprint"):
		#sprint_time -= delta
	#
	#var speed_multiplier := SPRINT_SPEED_MULTIPLIER if Input.is_action_pressed("sprint") and not is_crouching and sprint_time > 0.0 else 1.0
	#
	#if Input.is_action_just_released("sprint"):
		#_reset_sprint_time()
	
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
	_update_camera_motion(delta)

func _reset_sprint_time():
	await get_tree().create_timer(sprint_regen_time).timeout
	sprint_time = sprint_max_time

func _play_death():
	set_process(false)
	set_physics_process(false)
	
	enemy._on_player_caught()
	_pan_camera_to_enemy(enemy)
	

func _pan_camera_to_enemy(enemy: Node3D):
	var cam := _cam
	var target_pos = enemy_position

	var start_basis = _cam.global_transform.basis
	var target_basis = _cam.global_transform.looking_at(target_pos, Vector3.UP).basis

	enemy.position.y -= 0.5

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		cam,
		"global_transform:basis",
		target_basis,
		1.2
	)

	tween.finished.connect(
		func():
			_on_camera_pan_complete(enemy)
	)

func _on_camera_pan_complete(enemy):
	var anim = enemy.animation_player

	if anim.current_animation != "Attack":
		enemy.scream.pitch_scale = 1.5
		enemy.scream.play()
		anim.play("Attack")

	# Connect ONCE
	if not anim.animation_finished.is_connected(_attack_finished):
		anim.animation_finished.connect(_attack_finished.bind(enemy))

func _attack_finished(anim_name: String, enemy):
	# Only react to the Attack animation
	if anim_name != "Attack":
		return

	var anim = enemy.animation_player

	# Disconnect immediately (VERY IMPORTANT)
	if anim.animation_finished.is_connected(_attack_finished):
		anim.animation_finished.disconnect(_attack_finished)

	# Reload current scene
	var current_scene := get_tree().current_scene
	if current_scene == null:
		return

	Global.change_scene(
		current_scene.scene_file_path,
		"YOU DIED"
	)

func _input(event):
	if get_tree().paused:
		return

	if event is InputEventMouseMotion and not UI_horn.visible:
		rotation_degrees.y += event.relative.x * -_mouse_sensitivity
		_cam.rotation_degrees.x += event.relative.y * -_mouse_sensitivity
		_cam.rotation_degrees.x = clamp(_cam.rotation_degrees.x, -90, 90)


func _on_enemy_detection_body_entered(body):
	if body.name == "Enemy" or body.name == "Enemy2":
		enemy = body
		enemy_position = body.global_transform.origin + Vector3(0, 5.0, 0)
