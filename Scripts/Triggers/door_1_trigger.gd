extends Area3D

@export var one_shot := false
var fired := false

@onready var horn_obj: Node3D  = $Door_swing
@onready var horn_player : AudioPlayer = null
@onready var player : Player = null

func _ready():
	print("Area ready")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_exit)


func _on_body_entered(body):
	if body is CharacterBody3D and body.is_in_group("player"):
		horn_player = body.horn_player
		player = body
		if not horn_player.horn_started.is_connected(_try_fire):
			horn_player.horn_started.connect(_try_fire)
		_try_fire()



func _on_exit(body):
	if body.horn_player == horn_player:
		if horn_player.horn_started.is_connected(_try_fire):
			horn_player.horn_started.disconnect(_try_fire)
		horn_player = null

func _try_fire():
	if horn_player == null:
		return


	if fired and one_shot:
		return
		
	print("trying")
	

	if horn_player.is_playing:
		if horn_player.get_horn_state() ==  "OpenDoor1":
			fired = true
			_open()
		else:
			player.message_toast.show_message('"Am i playing it correctly?"', 4)
		
	
func _open():
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		self,
		"rotation:y",
		deg_to_rad(0), 
		1      
	)
