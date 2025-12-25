extends CharacterBody3D

var can_move = true
var set_pos_up = false
var set_pos_down = true
var timer_not_start = true
var _last_can_see := false

# -------------------------------------------------
# NODES
# -------------------------------------------------
@onready var nav: NavigationAgent3D = %NavigationAgent3D
@onready var animation_player: AnimationPlayer = $EnemyModel/AnimationPlayer
@onready var player = $"../Player"
@onready var eye: Node3D = %Eye
@onready var eye_ray: RayCast3D = %EyeRayCast
@onready var timer = $"../Timer"


# -------------------------------------------------
# CONFIG
# -------------------------------------------------
@export var roam_speed := 3.0
@export var chase_speed := 6.0
@export var search_speed := 1.5

@export var max_spotting_distance := 50.0
@export var chase_max_time := 8.0
@export var search_time := 6.0
@export var path_update_delay := 0.25
@export var catching_distance := 1.4

@export var not_reach_time = 4.0
@export var max_idle_time := 3.0
@export var max_stun_time := 5.0
# -------------------------------------------------
# STATE
# -------------------------------------------------
enum STATES { ROAM, CHASE, SEARCH, STUN, IDLE }
var state: STATES = STATES.ROAM

var chase_timer := 0.0
var search_timer := 0.0
var path_timer := 0.0
var stun_timer := 0.0
var idle_timer := 0.0
var current_speed := 0.0
var last_seen_player_pos: Vector3

# -------------------------------------------------
# READY
# -------------------------------------------------
func _ready() -> void:
	await get_tree().physics_frame
	timer.timeout.connect(_on_timer_timeout)
	Global.EnemyCall.connect(_start_chase)
	Global.EnemyStun.connect(_start_stun)
	animation_player.animation_finished.connect(_on_scream_finished)
	_pick_random_roam_target()

# -------------------------------------------------
# PHYSICS LOOP
# -------------------------------------------------
func _physics_process(delta: float) -> void:
	if not can_move:
		return
	#_apply_gravity(delta)

	match state:
		STATES.ROAM:
			_roam_state(delta)
		STATES.CHASE:
			_chase_state(delta)
		STATES.SEARCH:
			_search_state(delta)
		STATES.STUN:
			_stun(delta)
		STATES.IDLE:
			_idle_state(delta)

	_move_along_path(delta)

# -------------------------------------------------
# MOVEMENT
# -------------------------------------------------
func _move_along_path(delta: float) -> void:
	if nav.is_navigation_finished():
		velocity.x = 0
		velocity.z = 0
		move_and_slide()
		return

	var next_pos := nav.get_next_path_position()
	var dir := next_pos - global_position
	dir.y = 0

	if dir.length() > 0.05:
		dir = dir.normalized()
		velocity.x = dir.x * current_speed
		velocity.z = dir.z * current_speed
		rotation.y = lerp_angle(rotation.y, atan2(-dir.x, -dir.z), 10 * delta)

	else:
		velocity.x = 0
		velocity.z = 0

	move_and_slide()

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	else:
		velocity.y = 0

# -------------------------------------------------
# ROAM
# -------------------------------------------------
func _roam_state(delta: float) -> void:
	if not set_pos_down:
		$EnemyModel.position.y = -0.099
		$EnemyModel.rotation_degrees.z = 0.0
		set_pos_down = true
	if animation_player.current_animation != "Run ":
		animation_player.play("Run ")
	
	if timer_not_start:
		timer_not_start = false
		timer.start(not_reach_time)
	
	current_speed = roam_speed

	if nav.is_navigation_finished():
		_pick_random_roam_target()
		
	
	
	
	if is_player_in_view():
		_start_chase()
		#can_move = false
		#animation_player.play("Scream")
		#await animation_player.animation_finished
		#can_move = true
		#state = STATES.CHASE
		#chase_timer = chase_max_time

# -------------------------------------------------
# CHASE
# -------------------------------------------------

func _start_chase():
	state = STATES.CHASE
	chase_timer = chase_max_time
	path_timer = 0.0
	if not set_pos_up:
		$EnemyModel.position.y = 0.125
		$EnemyModel.rotation_degrees.z = 20.5
		set_pos_up = true
	
	can_move = false
	if animation_player.current_animation != "Scream":
		animation_player.play("Scream")
	
	

func _on_scream_finished(x) -> void:
	print(x)
	can_move = true

func _chase_state(delta: float) -> void:
	timer.stop()
	if animation_player.current_animation != "CrawlRun ":
		animation_player.play("CrawlRun ")
	current_speed = chase_speed
	chase_timer -= delta
	path_timer -= delta

	if path_timer <= 0.0:
		path_timer = path_update_delay
		nav.target_position = player.global_position

	if not is_line_of_sight_broken():
		chase_timer = chase_max_time
		last_seen_player_pos = player.global_position

	if chase_timer <= 0.0:
		state = STATES.SEARCH
		search_timer = search_time
		nav.target_position = last_seen_player_pos

	if global_position.distance_to(player.global_position) <= catching_distance:
		print("PLAYER CAUGHT")
		
	if Global.enemy_near_table and Global.player_under_table:
		_start_idle()
		

# -------------------------------------------------
# IDLE
# -------------------------------------------------

func _start_idle():
	state = STATES.IDLE
	idle_timer = max_idle_time
	if animation_player.current_animation != "Idle ":
		animation_player.play("Idle ")
	#animation_player.animation_finished.connect(_on_idle_finished)
	

func _on_idle_finished(x):
	print(x)
	pass

func _idle_state(delta: float):
	current_speed = 0.0
	idle_timer -= delta
	
	print(idle_timer)
	
	if idle_timer <= 0.0:
		state = STATES.SEARCH
		search_timer = search_time
		nav.target_position = last_seen_player_pos

# -------------------------------------------------
# SEARCH
# -------------------------------------------------
func _search_state(delta: float) -> void:
	if animation_player.current_animation != "Patrolling ":
		animation_player.play("Patrolling ")
	current_speed = search_speed
	search_timer -= delta

	if nav.is_navigation_finished():
		_pick_search_point()

	if is_player_in_view():
		state = STATES.CHASE
		chase_timer = chase_max_time

	if search_timer <= 0.0:
		set_pos_down = false
		set_pos_up = false
		state = STATES.ROAM
		_pick_random_roam_target()

# -------------------------------------------------
# TARGET PICKING
# -------------------------------------------------
func _pick_random_roam_target() -> void:
	timer_not_start = true
	var nav_map := get_world_3d().get_navigation_map()
	var pos := NavigationServer3D.map_get_random_point(nav_map, 1, true)
	nav.target_position = pos

func _pick_search_point() -> void:
	var offset := Vector3(
		randf_range(-6, 6),
		0,
		randf_range(-6, 6)
	)
	nav.target_position = last_seen_player_pos + offset

# -------------------------------------------------
# VISION
# -------------------------------------------------
func is_player_in_view() -> bool:
	var to_player = player.vision_target.global_position - eye.global_position
	if to_player.length() > max_spotting_distance:
		return false

	var fov := -eye.global_basis.z.normalized().dot(to_player.normalized()) > 0.5
	var visible = fov and not is_line_of_sight_broken()
	_log_vision(visible)
	return visible
	
func _log_vision(can_see: bool) -> void:
	if can_see == _last_can_see:
		return

	_last_can_see = can_see

	if can_see:
		print("ENEMY CAN SEE PLAYER")
	else:
		print("ENEMY LOST SIGHT OF PLAYER")

func is_line_of_sight_broken() -> bool:
	var space := get_world_3d().direct_space_state
	var from := eye.global_position
	var to = player.vision_target.global_position

	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]

	var result := space.intersect_ray(query)
	return result.size() > 0 and result.collider != player
	

func _start_stun():
	print("start stun")
	state = STATES.STUN
	stun_timer = max_stun_time
	can_move = false
	if animation_player.current_animation != "Death":
		animation_player.play("Death")
	animation_player.animation_finished.connect(_on_stun_finished)
	

func _on_stun_finished(x) -> void:
	print(x)
	can_move = true

func _stun(delta):
	current_speed = 0
	stun_timer -= delta
	print("Stunned")
	
	if stun_timer <= 0.0:
		print("Stunned")
		animation_player.play_backwards("Death")
		state = STATES.ROAM
	

func _on_timer_timeout():
	print("next pos")
	_pick_random_roam_target()
