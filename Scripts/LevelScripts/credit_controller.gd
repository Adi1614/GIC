extends Node

@export var developer_names := [
	"Aditya Singh",
	"Amman Raikar",
	"Arnav Kala",
	"Rahul Samedavar"
]

@export var developer_images := [
	preload("res://Assets/Images/card-1.png"),
	preload("res://Assets/Images/card-2.png"),
	preload("res://Assets/Images/card-3.png"),
	preload("res://Assets/Images/card-4.png"),
]

@export var image_display_time := 7.0
@export var fade_time := 1.5

@onready var shake_pivot := $"../CameraRig/ShakePivot"
@onready var camera := $"../CameraRig/ShakePivot/Camera3D"
@onready var fade_rect := $"../CanvasLayer/FadeRect"
@onready var title := $"../CanvasLayer/TitleLabel"
@onready var subtitle := $"../CanvasLayer/SubtitleLabel"
@onready var image_rect := $"../CanvasLayer/ImageRect"
@onready var name_label := $"../CanvasLayer/NameLabel"
@onready var flicker_light := $"../Environment/FlickerLight"

@export var stack_offset := Vector2(0, 12) # how much each image pushes the stack
@export var max_stack_rotation := 6.0      # degrees
@export var stack_z_index_start := 10

@export var cam_shake_strength := 0.050
@export var cam_shake_speed := 1



var stack_index := 0
var cam_noise_time := 0.0
var cam_base_transform : Transform3D
var cam_time := 0.0

func _ready():
	assert(developer_names.size() == developer_images.size())
	await fade_from_black()
	await show_intro_text()
	await play_developer_sequence()
	await show_final_message()
	
	# Optional: return to main menu
	Global.change_scene("res://Scenes/UI/main_menu.tscn", "PROJECT BLANKFACE")

func _process(delta):
	animate_camera_shake(delta)
	animate_light_flicker()

# ----------------------------------------------------
# CAMERA MOTION (Slow horror drift)
# ----------------------------------------------------
func animate_camera_shake(delta):
	cam_noise_time += delta * cam_shake_speed

	var rx = sin(cam_noise_time) * cam_shake_strength
	var ry = sin(cam_noise_time * 0.73) * cam_shake_strength * 0.6
	var rz = sin(cam_noise_time * 1.31) * cam_shake_strength * 0.35

	shake_pivot.rotation = Vector3(rx, ry, rz)



# ----------------------------------------------------
# LIGHT FLICKER (Subtle)
# ----------------------------------------------------
func animate_light_flicker():
	flicker_light.light_energy = 1.3 + randf() * 0.2

# ----------------------------------------------------
# FADE UTILITIES
# ----------------------------------------------------
func fade_from_black():
	fade_rect.modulate.a = 1.0
	await tween_alpha(fade_rect, 0.75)

func fade_to_black():
	await tween_alpha(fade_rect, 1.0)

func tween_alpha(node: CanvasItem, target: float):
	var tween = create_tween()
	tween.tween_property(node, "modulate:a", target, fade_time)
	await tween.finished

# ----------------------------------------------------
# INTRO TEXT
# ----------------------------------------------------
func show_intro_text():
	title.text = "THANK YOU FOR PLAYING"
	subtitle.text = "Early Prototype\nMore content coming soon"

	title.modulate.a = 0
	subtitle.modulate.a = 0

	await tween_alpha(title, 1.0)
	await tween_alpha(subtitle, 1.0)

	await get_tree().create_timer(3.0).timeout

	await tween_alpha(subtitle, 0.0)
	await tween_alpha(title, 0.0)

# ----------------------------------------------------
# DEVELOPER SEQUENCE
# ----------------------------------------------------
func play_developer_sequence():
	var viewport_size := get_viewport().get_visible_rect().size
	stack_index = 0

	var base_pos := Vector2(
		(viewport_size.x - image_rect.size.x) * 0.25,
		(viewport_size.y - image_rect.size.y) * 0.5 + 30
	)

	for i in developer_names.size():
		# Duplicate card so old ones stay
		var card := image_rect.duplicate()
		image_rect.get_parent().add_child(card)

		card.texture = developer_images[i]
		card.visible = true
		card.z_index = stack_z_index_start + stack_index

		# Initial drop state
		card.scale = Vector2(1.1, 1.1)
		card.rotation = deg_to_rad(randf_range(-max_stack_rotation, max_stack_rotation))
		card.position = Vector2(base_pos.x, -300)

		name_label.text = developer_names[i]
		name_label.modulate.a = 0

		# --- DROP ---
		var drop = create_tween()
		drop.set_trans(Tween.TRANS_QUAD)
		drop.set_ease(Tween.EASE_IN)

		var target_pos := base_pos + stack_offset * stack_index

		drop.tween_property(
			card,
			"position",
			target_pos,
			0.45
		)

		await drop.finished

		# --- IMPACT SQUASH ---
		var impact = create_tween()
		impact.set_parallel(true)

		impact.tween_property(card, "scale", Vector2(1.15, 0.92), 0.08)
		impact.tween_property(card, "rotation", card.rotation * 0.4, 0.08)

		await impact.finished

		# --- REBOUND ---
		var rebound = create_tween()
		rebound.set_parallel(true)
		rebound.set_trans(Tween.TRANS_BACK)
		rebound.set_ease(Tween.EASE_OUT)

		rebound.tween_property(card, "scale", Vector2.ONE, 0.25)
		rebound.tween_property(card, "rotation", card.rotation, 0.25)

		await rebound.finished

		# --- NAME AFTER IMPACT ---
		await get_tree().create_timer(0.15).timeout
		await tween_alpha(name_label, 1.0)

		await get_tree().create_timer(2.2).timeout

		name_label.modulate.a = 0

		stack_index += 1
		await get_tree().create_timer(0.35).timeout

# ----------------------------------------------------
# FINAL MESSAGE
# ----------------------------------------------------
func show_final_message():
	name_label.text = "This is only the beginning."
	name_label.modulate.a = 0

	await tween_alpha(name_label, 1.0)
	await get_tree().create_timer(3.0).timeout
	await tween_alpha(name_label, 0.0)

	name_label.text = "See you again."
	await tween_alpha(name_label, 1.0)
	await get_tree().create_timer(3.0).timeout
	await fade_to_black()
