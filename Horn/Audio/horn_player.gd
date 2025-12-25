extends Node3D
class_name AudioPlayer


var can_play = false


var horn_state: Dictionary = {
	"EnemyStun": [0.5, 1.0, 1.0, 0.7, 0.0],
	"LiftObj": [1.0, 0.3, 0.0, 1.0, 0.4],
	"OpenDoor1": [0.6, 0.1, 0.5, 0.7, 0.2],
	"Help": [1.0, 1.0, 1.0, 1.0, 0.0],
	"Machine 1": [0.6, 0.7, 0.6, 0.7, 0.6],
	"Machine 2": [0.6, 0.9, 0.6, 0.9, 0.6],
	"Machine 3": [0.9, 1.0, 1.0, 1.0, 0.1]
	}
	# pitch, distor, delay, phaser, compressor(vol)

@export var timeout_horn = 5.0

@onready var player:AudioStreamPlayer3D = %Player
@onready var bus_index = AudioServer.get_bus_index("HornBus")

@onready var pitch_fx = AudioServer.get_bus_effect(bus_index, 0)
@onready var distortion_fx = AudioServer.get_bus_effect(bus_index, 1)
@onready var delay_fx = AudioServer.get_bus_effect(bus_index, 2)
@onready var phaser_fx = AudioServer.get_bus_effect(bus_index, 3)
@onready var compressor_fx = AudioServer.get_bus_effect(bus_index, 4)




@onready var PitchSlider : Slider = %PitchSlider
@onready var DistortionSlider : Slider = %DistortionSlider
@onready var DelaySlider : Slider = %DelaySlider
@onready var PhaserSlider : Slider = %PhaserSlider
@onready var CompressorSlider : Slider = %CompressorSlider

signal horn_started
signal horn_stopped
var is_playing : bool = false


#
func playHorn():
	if is_playing:
		return
		
	is_playing = true
	player.stop()
	set_pitch(PitchSlider.value)
	set_distortion(DistortionSlider.value)
	set_delay(DelaySlider.value)
	set_phaser(PhaserSlider.value)
	set_compression(CompressorSlider.value)
	print("Playing")
	horn_started.emit()
	player.play()
	horn_stopped.emit()

func _ready():
	AudioServer.set_bus_volume_db(1, -15.0)
	print(bus_index)
	#player.play()
	pass
	
func _input(event):
	if event.is_action_pressed("playHorn") and can_play:
		can_play = false
		var state = ""
		var amount_list = [PitchSlider.value, DistortionSlider.value, DelaySlider.value, PhaserSlider.value, CompressorSlider.value]
		for key in horn_state.keys():
			if horn_state[key] == amount_list:
				state = key

		print(state)
		Global._get_horn_state(state)
		
		playHorn()
		await get_tree().create_timer(timeout_horn).timeout
		can_play = true
		is_playing = false

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
	
func get_horn_state():
	var state = ""
	var amount_list = [PitchSlider.value, DistortionSlider.value, DelaySlider.value, PhaserSlider.value, CompressorSlider.value]
	for key in horn_state.keys():
		if horn_state[key] == amount_list:
			state = key
	return state
