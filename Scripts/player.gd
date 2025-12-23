extends CharacterBody3D
class_name Player

@onready var cam = $Camera3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * 0.55
		cam.rotation_degrees.x -= event.relative.y * 0.18
		cam.rotation_degrees.x = clamp(cam.rotation_degrees.x, -60, 80)


func _physics_process(delta):
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED * delta * 75
		velocity.z = direction.z * SPEED * delta * 75
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
