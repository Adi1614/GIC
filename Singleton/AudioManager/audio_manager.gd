extends AudioStreamPlayer

var background_music = preload("res://Assets/Sounds/Background/Background Audio.wav")

func _play_music(music: AudioStream, volume = 0.0):
	if stream == music:
		return

	stream = music
	volume_db = volume
	play()
	
func play_music_level():
	_play_music(background_music)
