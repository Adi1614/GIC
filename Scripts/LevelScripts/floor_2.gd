extends Node3D

@onready var player = $Player
@onready var light_1 = $OmniLight3D
@onready var light_2 = $OmniLight3D2
@onready var light_3 = $OmniLight3D3

var machine1 = false
var machine2 = false
var machine3 = false

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.Machine.connect(_machine_complete)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if machine1 and machine2 and machine3:
		print("COMPLETED")

func _machine_complete(id : int):
	match id:
		1:
			machine1 = true
			light_1.light_color = Color(0.0, 0.663, 0.0, 1.0)
		2:
			machine2 = true
			light_2.light_color = Color(0.0, 0.663, 0.0, 1.0)
		3:
			machine3 = true
			light_3.light_color = Color(0.0, 0.663, 0.0, 1.0)

func _on_area_3d_body_entered(body):
	if body.name == "Player" and not machine1:
		Global.ShowInteractUI(1)

func _on_area_3d_body_exited(body):
	if body.name == "Player":
		Global.HideUI()

func _on_machine_2_body_entered(body):
	if body.name == "Player" and not machine2:
		Global.ShowInteractUI(1)

func _on_machine_2_body_exited(body):
	if body.name == "Player":
		Global.HideUI()

func _on_machine_3_body_entered(body):
	if body.name == "Player" and not machine3:
		Global.ShowInteractUI(1)

func _on_machine_3_body_exited(body):
	if body.name == "Player":
		Global.HideUI()
