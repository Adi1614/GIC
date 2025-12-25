extends CanvasLayer

signal closed

# -------------------------------------------------
# TAB BUTTONS
# -------------------------------------------------
@onready var tab_buttons: Control = $TabButtons
@onready var music_tab_btn: Button = $TabButtons/MusicButton
@onready var controls_tab_btn: Button = $TabButtons/ControlsButton
@onready var exit_tab_btn: Button = $TabButtons/ExitButton

# -------------------------------------------------
# MENUS
# -------------------------------------------------
@onready var music_menu: Control = $MusicMenu
@onready var controls_menu: Control = $ControlsMenu

# -------------------------------------------------
# MUSIC MENU WIDGETS
# -------------------------------------------------
@onready var master_slider: HSlider = $MusicMenu/MasterSlider
@onready var music_slider: HSlider = $MusicMenu/MusicSlider
@onready var sfx_slider: HSlider = $MusicMenu/SFXSlider
@onready var apply_audio_btn: Button = $MusicMenu/ApplyButton
@onready var music_back_btn: Button = $MusicMenu/BackButton

# -------------------------------------------------
# CONTROLS MENU WIDGETS
# -------------------------------------------------
@onready var remap_container: VBoxContainer = $ControlsMenu/RemapContainer
@onready var confirm_controls_btn: Button = $ControlsMenu/ConfirmButton
@onready var controls_back_btn: Button = $ControlsMenu/BackButton
#--------------------------------------------------

const FONT : LabelSettings= preload("res://Assets/misc/font.tres")

# -------------------------------------------------
var awaiting_action := ""
var temp_bindings: Dictionary = {}
var awaiting_button: Button = null
# RESERVED ACTIONS THAT CANNOT BE REMAPPED
var reserved_actions := ["pause", "ui_cancel"]

# -------------------------------------------------
func _ready() -> void:
	_show_tab_buttons()
	
	_configure_audio_sliders()  # 🔴 REQUIRED
	_load_audio()               # ✅ NOW WORKS
	_build_controls_menu()

	music_tab_btn.pressed.connect(_open_music_menu)
	controls_tab_btn.pressed.connect(_open_controls_menu)
	exit_tab_btn.pressed.connect(_close_settings)

	music_back_btn.pressed.connect(_show_tab_buttons)
	controls_back_btn.pressed.connect(_show_tab_buttons)

	apply_audio_btn.pressed.connect(_apply_audio_settings)
	confirm_controls_btn.pressed.connect(_apply_control_settings)
# -------------------------------------------------
# MENU VISIBILITY
# -------------------------------------------------
func _show_tab_buttons() -> void:
	# Discard ALL temporary key changes
	_reset_controls_to_project_settings()

	tab_buttons.show()
	music_menu.hide()
	controls_menu.hide()

func _open_music_menu() -> void:
	tab_buttons.hide()
	music_menu.show()
	controls_menu.hide()
	
func _open_controls_menu() -> void:
	tab_buttons.hide()
	music_menu.hide()
	controls_menu.show()

	# Always rebuild from Project Settings
	_reset_controls_to_project_settings()
# -------------------------------------------------
# AUDIO
# -------------------------------------------------
func _load_audio() -> void:
	_set_slider_from_bus(master_slider, "Master")
	_set_slider_from_bus(music_slider, "Music")
	_set_slider_from_bus(sfx_slider, "SFX")

func _configure_audio_sliders() -> void:
	for slider in [master_slider, music_slider, sfx_slider]:
		slider.min_value = 0.0
		slider.max_value = 1.0
		slider.step = 0.01

func _set_slider_from_bus(slider: HSlider, bus_name: String) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		push_error("Audio bus not found: %s" % bus_name)
		return

	var db := AudioServer.get_bus_volume_db(bus_index)
	slider.value = db_to_linear(db)

func _apply_audio_settings() -> void:
	_set_bus("Master", master_slider.value)
	_set_bus("Music", music_slider.value)
	_set_bus("SFX", sfx_slider.value)

func _set_bus(bus_name: String, value: float) -> void:
	var bus := AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))

# -------------------------------------------------
# CONTROLS (KEY REMAPPING UI)
# -------------------------------------------------
func _build_controls_menu() -> void:
	# Clear old UI
	for child in remap_container.get_children():
		child.queue_free()

	# IMPORTANT: Always start from InputMap
	for action in InputMap.get_actions():
		if action.begins_with("ui_") or action in reserved_actions:
			continue

		var row := HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		# Label (action name)
		var label := Label.new()
		label.text = action
		label.label_settings = FONT
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		# Spacer
		var spacer := Control.new()
		spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		# Button (shows current key)
		var btn := Button.new()
		btn.custom_minimum_size.x = 200
		btn.text = "%s" % [_get_display_key(action)]

		btn.pressed.connect(_start_remap.bind(action, btn))

		row.add_child(label)
		row.add_child(spacer)
		row.add_child(btn)

		remap_container.add_child(row)


func _start_remap(action: String, button: Button) -> void:
	awaiting_action = action
	awaiting_button = button
	button.text = "Press any key (ESC to cancel)"
	
func _input(event: InputEvent) -> void:
	if awaiting_action == "":
		return

	if event is InputEventKey and event.pressed and not event.echo:
		# ESC cancels remap
		if event.physical_keycode == Key.KEY_ESCAPE:
			_cancel_remap()
			return

		var keycode = event.physical_keycode

		# Resolve conflicts FIRST
		_resolve_conflicts(keycode, awaiting_action)

		# Assign to current action
		var ev := InputEventKey.new()
		ev.physical_keycode = keycode
		ev.pressed = true
		temp_bindings[awaiting_action] = ev

		awaiting_action = ""
		awaiting_button = null
		_build_controls_menu()



func _cancel_remap() -> void:
	if awaiting_action != "" and awaiting_button:
		var key_text := _get_display_key(awaiting_action)
		awaiting_button.text = "%s" % [key_text]

	awaiting_action = ""
	awaiting_button = null

func _apply_control_settings() -> void:
	for action in temp_bindings.keys():
		InputMap.action_erase_events(action)

		var ev = temp_bindings[action]
		if ev != null:
			InputMap.action_add_event(action, ev)

	temp_bindings.clear()
	_build_controls_menu()


func _reset_controls_to_project_settings() -> void:
	awaiting_action = ""
	awaiting_button = null
	temp_bindings.clear()
	_build_controls_menu()


# -------------------------------------------------
# HELPERS
# -------------------------------------------------
func _get_action_key(action: String) -> String:
	var events := InputMap.action_get_events(action)
	for e in events:
		if e is InputEventKey:
			return OS.get_keycode_string(e.physical_keycode)
	return "Unassigned"
	
func _get_display_key(action: String) -> String:
	# Temp override exists
	if temp_bindings.has(action):
		var ev = temp_bindings[action]
		if ev == null:
			return "Unassigned"
		return OS.get_keycode_string(ev.physical_keycode)

	# Otherwise from Project Settings
	return _get_action_key(action)

func _resolve_conflicts(new_keycode: int, target_action: String) -> void:
	for action in InputMap.get_actions():
		if action == target_action:
			continue
		if action.begins_with("ui_") or action in reserved_actions:
			continue

		var effective_key := _get_effective_keycode(action)

		# Only unassign if this action ACTUALLY uses the same key
		if effective_key == new_keycode:
			temp_bindings[action] = null

func _get_effective_keycode(action: String) -> int:
	# Temp binding overrides everything
	if temp_bindings.has(action):
		var ev = temp_bindings[action]
		return  0 if ev == null else ev.physical_keycode

	# Otherwise read from InputMap
	for ev in InputMap.action_get_events(action):
		if ev is InputEventKey:
			return ev.physical_keycode

	return 0


# -------------------------------------------------
# EXIT SETTINGS
# -------------------------------------------------
func _close_settings() -> void:
	emit_signal("closed")
