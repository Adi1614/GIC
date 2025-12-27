extends Node

@onready var dialogue_player: AudioStreamPlayer = $DialoguePlayer
@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var wooshing_player = $Wooshing

# -------------------------------------------------
# BACKGROUND MUSIC
# -------------------------------------------------
var background_music := preload("res://Assets/Sounds/Background/Background Audio.wav")
var wooshing = preload("res://Assets/Sounds/Background/mixkit-horror-sci-fi-wind-tunnel-894.wav")

func _play_music(music: AudioStream, player: AudioStreamPlayer, volume := 0.0):
	if player.stream == music and player.playing:
		return

	player.stream = music
	player.volume_db = volume
	player.play()

func play_music_level():
	_play_music(background_music, music_player)
	_play_music(wooshing, wooshing_player)

func stop_music():
	music_player.stop()

# -------------------------------------------------
# DIALOGUE AUDIO MAP
# -------------------------------------------------
#var dialogue_audio := {
	#3: preload("res://Assets/Sounds/LevelAudio/3.mp3"),
	#4: preload("res://Assets/Sounds/LevelAudio/4.mp3"),
	#5: preload("res://Assets/Sounds/LevelAudio/5.mp3"),
	#7: preload("res://Assets/Sounds/LevelAudio/7.mp3"),
	#8: preload("res://Assets/Sounds/LevelAudio/8.mp3"),
	#9: preload("res://Assets/Sounds/LevelAudio/9.mp3"),
	#10: preload("res://Assets/Sounds/LevelAudio/10.mp3"),
	#11: preload("res://Assets/Sounds/Cutscene/cut-1-1.wav"),
	#12: preload("res://Assets/Sounds/Cutscene/cut-1-2.wav"),
	#13: preload("res://Assets/Sounds/Cutscene/cut-1-3.wav"),
	#14: preload("res://Assets/Sounds/Cutscene/cut-1-4.wav"),
	#15: preload("res://Assets/Sounds/Cutscene/cut-1-5.wav"),
	#16: preload("res://Assets/Sounds/Cutscene/cut-1-6.wav"),
	#17: preload("res://Assets/Sounds/Cutscene/cut-1-7.wav"),
#}
var dialogue_audio := {
	3: { # level 1 storyline
		"stream": preload("res://Assets/Sounds/LevelAudio/3.mp3"),
		"one_time": true
	},
	4: {
		"stream": preload("res://Assets/Sounds/LevelAudio/4.mp3"),
		"one_time": true
	},
	5: {
		"stream": preload("res://Assets/Sounds/LevelAudio/5.mp3"),
		"one_time": false
	},
	7: { # level 1 story end
		"stream": preload("res://Assets/Sounds/LevelAudio/7.mp3"),
		"one_time": true
	},
	8: { # level 2
		"stream": preload("res://Assets/Sounds/LevelAudio/8.mp3"),
		"one_time": true
	},
	9: {
		"stream": preload("res://Assets/Sounds/LevelAudio/9.mp3"),
		"one_time": true
	},
	10: { # level 3
		"stream": preload("res://Assets/Sounds/LevelAudio/10.mp3"),
		"one_time": true
	},
	11: { # cutscene
		"stream": preload("res://Assets/Sounds/Cutscene/cut-1-1.wav"),
		"one_time": true
	},
	12: { # cutscene
		"stream": preload("res://Assets/Sounds/Cutscene/cut-1-2.wav"),
		"one_time": true
	},
	13: { # cutscene
		"stream": preload("res://Assets/Sounds/Cutscene/cut-1-3.wav"),
		"one_time": true
	},
	14: { # cutscene
		"stream": preload("res://Assets/Sounds/Cutscene/cut-1-4.wav"),
		"one_time": true
	},
	15: { # cutscene
		"stream": preload("res://Assets/Sounds/Cutscene/cut-1-5.wav"),
		"one_time": true
	},
	16: { # cutscene
		"stream": preload("res://Assets/Sounds/Cutscene/cut-1-6.wav"),
		"one_time": true
	},
	17: { # cutscene
		"stream": preload("res://Assets/Sounds/Cutscene/cut-1-7.wav"),
		"one_time": true
	}
}


var _current_dialogue_id := -1

func _ready():
	Global.ShowUi.connect(_on_show_ui)
	Global.HideUi.connect(_on_hide_ui)
	dialogue_player.finished.connect(_on_dialogue_finished)

# -------------------------------------------------
# REACT TO UI EVENTS
# -------------------------------------------------
#func _on_show_ui(id: int):
	## Ignore if same dialogue already playing
	#if _current_dialogue_id == id:
		#return
#
	## Stop previous dialogue audio
	#if dialogue_player.playing:
		#dialogue_player.stop()
#
	#_current_dialogue_id = id
#
	## No audio for this dialogue → nothing to do
	#if not dialogue_audio.has(id):
		#return
#
	#dialogue_player.stream = dialogue_audio[id]
	#dialogue_player.play()
	
func _on_show_ui(id: int):
	# Same dialogue already playing
	if _current_dialogue_id == id:
		return

	# No audio for this UI → ignore
	if not dialogue_audio.has(id):
		return

	var entry = dialogue_audio[id]

	# One-time protection
	if entry.one_time and Global.is_dialogue_completed(id):
		return

	# If a dialogue is already playing, DO NOT interrupt it
	if dialogue_player.playing:
		return

	# Play this dialogue
	_current_dialogue_id = id
	dialogue_player.stream = entry.stream
	dialogue_player.play()



func _on_hide_ui():
	# UI hidden manually → stop dialogue audio
	if dialogue_player.playing:
		dialogue_player.stop()

	_current_dialogue_id = -1

# -------------------------------------------------
# DIALOGUE FINISHED
# -------------------------------------------------
func _on_dialogue_finished():
	if _current_dialogue_id == -1:
		return
		
	_current_dialogue_id = -1
	Global.HideUI()
