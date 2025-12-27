extends Node3D

var intro = false
var sequence_found = false
var door_area = false
var level_complete = false

@onready var enemy = $Enemy
@onready var player = $Player
@onready var horn = $Horn
@onready var player_horn = $Player/Camera3D/Horn
@onready var door = $Exit/Door/CollisionShape3D
@onready var door_swing = $Door_swing

func _ready():
	if Global.got_horn:
		horn.queue_free()
	AudioManager.play_music_level()
	Global.OpenDoor.connect(_door_open)
	if not intro:
		Global.ShowInteractUI(3)
		intro = true

func _door_open():
	if door_area:
		door.disabled = true
		level_complete = true

func _process(delta):
	if not $Walkie.playing:
		$Walkie.play()
	if level_complete:
		door_swing.rotation_degrees.y += move_toward(0, 90, 1)
		door_swing.rotation_degrees.y = clamp(door_swing.rotation_degrees.y, -90, 0)

func _on_area_3d_body_entered(body):
	if body.name == "Player" and not Global.got_horn:
		Global.ShowInteractUI(4)
		Global.got_horn = true
		player_horn.show()
		horn.queue_free()

func _on_note_1_body_entered(body):
	if body.name == "Player" and not player.is_crouching:
		sequence_found = true
		Global.Show_Note(4)

func _on_note_1_body_exited(body):
	if body.name == "Player":
		Global.HideUI()

func _on_exit_activation_body_entered(body):
	if body.name == "Player":
		door_area = true
		if not sequence_found:
			Global.ShowInteractUI(5)
		
		elif sequence_found:
			Global.ShowInteractUI(6)

func _on_exit_activation_body_exited(body):
	if body.name == "Player":
		door_area = false
		if not AudioManager.dialogue_player.playing:
			Global.HideUI()

func _on_note_2_body_entered(body):
	if body.name == "Player" and Global.got_horn:
		Global.Show_Note(5)

func _on_note_2_body_exited(body):
	if body.name == "Player":
		Global.HideUI()

func _on_next_level_body_entered(body):
	if body.name == "Player" and level_complete:
		enemy.can_move = false
		Global.change_scene(
			"res://Scenes/Level/floor_2.tscn",
			"FLOOR 2 - Power Override"
		)
		
