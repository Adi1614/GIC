extends Control

@onready var label: Label = $Panel/Label

var _tween: Tween

func show_message(
	message: String,
	display_time: float,
	fade_time: float = 0.4
) -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	label.text = message
	visible = true
	modulate.a = 0.0

	# Kill any running animation
	if _tween and _tween.is_running():
		_tween.kill()

	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.set_ease(Tween.EASE_OUT)

	# Fade in
	_tween.tween_property(self, "modulate:a", 1.0, fade_time)

	# Hold
	_tween.tween_interval(display_time)

	# Fade out
	_tween.tween_property(self, "modulate:a", 0.0, fade_time)

	# Cleanup
	_tween.tween_callback(func():
		visible = false
	)
