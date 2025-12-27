extends CanvasLayer

@onready var fade_rect: ColorRect = $FadeRect
@onready var floor_label: Label = $FloorLabel
@onready var change_sound = $AudioStreamPlayer

var _busy := false
var _current_tween: Tween = null

func _ready():
	# Always visible, alpha controls visibility
	fade_rect.visible = true
	fade_rect.modulate.a = 0.0

	# IMPORTANT: do not block clicks
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	floor_label.visible = false

	Global.RequestSceneChange.connect(request_scene_change)

# ------------------------------------------------
# PUBLIC ENTRY POINT
# ------------------------------------------------
func request_scene_change(scene_path: String, floor_name: String = ""):
	if _busy:
		return

	_busy = true
	_fade_to_black(scene_path, floor_name)

# ------------------------------------------------
# FADE LOGIC
# ------------------------------------------------
func _fade_to_black(scene_path: String, floor_name: String):
	_kill_tween()
	
	Global.reset_dialogues()
	_current_tween = create_tween()
	_current_tween.tween_property(
		fade_rect,
		"modulate:a",
		1.0,
		1
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	_current_tween.finished.connect(
		func(): _on_fade_in_finished(scene_path, floor_name)
	)

func _on_fade_in_finished(scene_path: String, floor_name: String):
	# Change scene while black
	Global.force_resume()
	get_tree().change_scene_to_file(scene_path)

	# Show floor title
	if floor_name != "":
		floor_label.text = floor_name
		floor_label.visible = true
		change_sound.play()
		await get_tree().create_timer(2).timeout
		floor_label.visible = false

	_fade_from_black()

func _fade_from_black():
	_kill_tween()

	_current_tween = create_tween()
	_current_tween.tween_property(
		fade_rect,
		"modulate:a",
		0.0,
		1
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	_current_tween.finished.connect(_on_fade_out_finished)

func _on_fade_out_finished():
	_busy = false

func _kill_tween():
	if _current_tween and _current_tween.is_running():
		_current_tween.kill()
	_current_tween = null
