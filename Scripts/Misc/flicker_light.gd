extends SpotLight3D

@export var base_energy := 1.0
@export var flicker_strength := 0.3
@export var flicker_speed := 3.0

@export var burst_energy := 4.0
@export var burst_duration := 0.15
@export var burst_chance := 0.015

@export var blackout_chance := 0.01
@export var blackout_duration := 0.5

var noise := FastNoiseLite.new()
var time := 0.0
var burst_timer := 0.0
var blackout_timer := 0.0

func _ready():
	randomize()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 1.5

func _process(delta):
	time += delta * flicker_speed

	if burst_timer > 0:
		burst_timer -= delta
		light_energy = burst_energy
		return

	if blackout_timer > 0:
		blackout_timer -= delta
		light_energy = 0
		return

	if randf() < burst_chance:
		burst_timer = burst_duration
		return

	if randf() < blackout_chance:
		blackout_timer = blackout_duration
		return

	var flicker = noise.get_noise_1d(time)
	light_energy = base_energy + flicker * flicker_strength
