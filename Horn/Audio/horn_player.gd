extends Node3D
class_name AudioPlayer

@onready var button: Button = $Control/NinePatchRect/VBoxContainer2/Button
@onready var button_2: Button = $Control/NinePatchRect/VBoxContainer2/Button2
@onready var button_3: Button = $Control/NinePatchRect/VBoxContainer2/Button3

@export var stun_limit: int = 3
@export var timeout_horn := 5.0

var can_play := true
var stun_counter: int = 0

var horn_state: Dictionary = {
	"EnemyStun": [0.5, 1.0, 1.0, 0.7, 0.0],
	"LiftObj": [1.0, 0.3, 0.0, 1.0, 0.4],
	"Door": [0.3, 0.2, 0.4, 0.1, 0.5],
	"Help": [1.0, 1.0, 1.0, 1.0, 0.0],
	"Machine 1": [0.6, 0.7, 0.6, 0.7, 0.6],
	"Machine 2": [0.6, 0.9, 0.6, 0.9, 0.6],
	"Machine 3": [0.9, 1.0, 1.0, 1.0, 0.1]
}

@onready var player = %Player
@onready var bus_index = AudioServer.get_bus_index("HornBus")

@onready var pitch_fx = AudioServer.get_bus_effect(bus_index, 0)
@onready var distortion_fx = AudioServer.get_bus_effect(bus_index, 1)
@onready var delay_fx = AudioServer.get_bus_effect(bus_index, 2)
@onready var phaser_fx = AudioServer.get_bus_effect(bus_index, 3)
@onready var compressor_fx = AudioServer.get_bus_effect(bus_index, 4)

@onready var PitchSlider: Slider = %PitchSlider
@onready var DistortionSlider: Slider = %DistortionSlider
@onready var DelaySlider: Slider = %DelaySlider
@onready var PhaserSlider: Slider = %PhaserSlider
@onready var CompressorSlider: Slider = %CompressorSlider

# ---------------- COOLDOWN UI ----------------
@onready var cooldown_bar: ProgressBar = %HornCooldownBar
var cooldown_time_left := 0.0
# --------------------------------------------

# ================= READY =================
func _ready():
	cooldown_bar.min_value = 0.0
	cooldown_bar.max_value = 1.0
	cooldown_bar.value = 1.0
	cooldown_bar.hide()

	AudioServer.set_bus_volume_db(1, -15.0)

	button.pressed.connect(_enemy_stun_hotkey_pressed)
	button_2.pressed.connect(_open_door_hotkey_pressed)
	button_3.pressed.connect(_help_hotkey_pressed)

	if not Global.StunHotkey.contains("???"):
		button.text = "STUN ENEMY, uses left: " + str(stun_limit - stun_counter)
	else:
		button.text = "???"

	button_2.text = Global.OpenDoorHotkey

# ================= INPUT =================
func _input(event):
	if event.is_action_pressed("playHorn") and can_play and Global.got_horn:
		can_play = false

		var state := ""
		var amount_list := [
			PitchSlider.value,
			DistortionSlider.value,
			DelaySlider.value,
			PhaserSlider.value,
			CompressorSlider.value
		]

		for key in horn_state.keys():
			if horn_state[key] == amount_list:
				state = key
				match state:
					"EnemyStun":
						button.text = "STUN ENEMY, uses left: " + str(stun_limit - stun_counter - 1)
						Global.StunHotkey = button.text
					"Door":
						Global.OpenDoorHotkey = "OPEN DOOR"
						button_2.text = "OPEN DOOR"
					"Help":
						Global.HelpHotkey = "HELP"
						button_3.text = "HELP"

		if state == "EnemyStun":
			if stun_counter < stun_limit:
				Global._get_horn_state(state)
				playHorn()
				stun_counter += 1
				start_horn_cooldown()

		else:
			Global._get_horn_state(state)
			playHorn()
			start_horn_cooldown()

# ================= COOLDOWN =================
func start_horn_cooldown():
	cooldown_time_left = timeout_horn
	cooldown_bar.value = 1.0
	cooldown_bar.show()

func _process(delta):
	# Automatically pauses when game is paused
	if cooldown_time_left <= 0.0:
		return

	cooldown_time_left -= delta
	cooldown_time_left = max(cooldown_time_left, 0.0)

	# Reverse fill (full → empty)
	cooldown_bar.value = cooldown_time_left / timeout_horn

	if cooldown_time_left == 0.0:
		cooldown_bar.hide()
		can_play = true

# ================= AUDIO =================
func playHorn():
	player.stop()
	set_pitch(PitchSlider.value)
	set_distortion(DistortionSlider.value)
	set_delay(DelaySlider.value)
	set_phaser(PhaserSlider.value)
	set_compression(CompressorSlider.value)
	player.play()

# ================= HOTKEYS =================
func set_hotkey(amount_list: Array):
	PitchSlider.value = amount_list[0]
	DistortionSlider.value = amount_list[1]
	DelaySlider.value = amount_list[2]
	PhaserSlider.value = amount_list[3]
	CompressorSlider.value = amount_list[4]

func _enemy_stun_hotkey_pressed():
	if button.text.contains("STUN ENEMY"):
		set_hotkey(horn_state["EnemyStun"])

func _open_door_hotkey_pressed():
	if button_2.text == "OPEN DOOR":
		set_hotkey(horn_state["Door"])

func _help_hotkey_pressed():
	if button_3.text == "HELP":
		set_hotkey(horn_state["Help"])

# ================= FX =================
func set_pitch(value):
	if value == 0.0:
		value = 0.01
	pitch_fx.pitch_scale = value * 4

func set_distortion(value):
	if value == 0.0:
		value = 0.01
	distortion_fx.drive = value

func set_delay(amount):
	if amount == 0.0:
		amount = 0.01
	delay_fx.tap1_delay_ms = lerp(120.0, 500.0, amount)

func set_phaser(amount):
	if amount == 0.0:
		amount = 0.01
	phaser_fx.rate_hz = lerp(0.2, 0.6, amount)
	phaser_fx.depth = lerp(0.2, 0.5, amount)
	phaser_fx.feedback = lerp(0.1, 0.35, amount)

func set_compression(amount):
	if amount == 0.0:
		amount = 0.01
	compressor_fx.threshold = lerp(-8.0, -28.0, amount / 2)
	compressor_fx.ratio = lerp(1.5, 6.0, amount / 2)
	compressor_fx.attack_us = lerp(0.02, 0.005, amount / 2)
	compressor_fx.release_ms = lerp(50, 1000, amount / 2)
