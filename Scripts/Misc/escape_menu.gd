extends CanvasLayer
@onready var escape_menu: CanvasLayer = $"."
@onready var resume_btn: Button = $Control/ResumeButton
@onready var settings_btn: Button = $Control/SettingsButton
@onready var main_menu_btn: Button = $Control/MainMenuButton

@export var settings_scene: PackedScene
@export var main_menu_scene: PackedScene

var settings_instance: CanvasLayer = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	resume_btn.pressed.connect(Global.resume_game)
	settings_btn.pressed.connect(_open_settings)
	main_menu_btn.pressed.connect(_go_to_main_menu)

func _open_settings() -> void:
	if settings_instance:
		return
	
	hide()
	settings_instance = settings_scene.instantiate()
	add_child(settings_instance)

	settings_instance.closed.connect(func():
		settings_instance.queue_free()
		show()
		settings_instance = null
	)

func _go_to_main_menu() -> void:
	Global.force_resume()
	AudioManager.dialogue_player.stop()
	get_tree().change_scene_to_packed(main_menu_scene)
