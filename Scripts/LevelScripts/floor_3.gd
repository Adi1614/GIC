extends Node3D

var exit_door_area = false
var level_complete = false
@onready var door = $Door_swing/Door/CollisionShape3D
@onready var door_swing = $Door_swing
@onready var horn_player = $Player/Camera3D/Horn/HornPlayer
@onready var enemy = $Enemy
@onready var enemy_2 = $Enemy2
@onready var timer_call_enemy = $Timer2

# Called when the node enters the scene tree for the first time.
func _ready():
	AudioManager.play_music_level()
	Global.Help.connect(_level_complete)
	await get_tree().create_timer(15).timeout
	_call_enemy()
	
	
func _call_enemy():
	horn_player.set_hotkey([0.1, 1.0, 0.0, 0.0, 0.0])
	horn_player.playHorn()
	Global._get_horn_state("")
	await get_tree().create_timer(15).timeout
	Global.ShowInteractUI(20)
	_call_enemy()
	await get_tree().create_timer(8.0).timeout
	Global.HideUI()

func _process(delta):
	if level_complete:
		door_swing.rotation_degrees.y += move_toward(0, 90, 1)
		door_swing.rotation_degrees.y =clamp(door_swing.rotation_degrees.y, -90, 0.0)

func _level_complete():
	if exit_door_area:
		door.disabled = true
		level_complete = true

func _on_level_inititalte_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		Global.ShowInteractUI(10)

#func _on_level_inititalte_body_exited(body: Node3D) -> void:
	#if body.name == "Player":
		#Global.HideUI()

func _on_dead_end_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		Global.HideUI()

func _on_dead_end_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		Global.ShowInteractUI(2)

func _on_exit_door_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		exit_door_area = true
		Global.ShowInteractUI(19)

func _on_exit_door_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		exit_door_area = false
		Global.HideUI()

func _on_credit_body_entered(body):
	print(body)
	if body.name == "Player" and level_complete:
		print("come")
		Global.change_scene(
			"res://Scenes/Level/credits.tscn",
			""
		)
