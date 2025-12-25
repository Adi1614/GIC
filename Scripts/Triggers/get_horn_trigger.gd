extends Area3D

@export var one_shot := true
var fired := false

@onready var horn_obj: Node3D  = $Sketchfab_Scene

func _ready():
	print("Area ready")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if fired and one_shot:
		return

	if body is CharacterBody3D and body.is_in_group("player"):
		fired = true
		trigger_event(body)

func trigger_event(body):
	body.get_horn()
	horn_obj.visible = false
	body_entered.disconnect(_on_body_entered)
