extends GridMap

@export var flicker_light_scene: PackedScene
@export var light_offset := Vector3(0, -0.2, 0)
var ceiling_light_item_id := 1

func _ready():
	await get_tree().process_frame
	await get_tree().process_frame
	spawn_lights()

func spawn_lights():
	for cell in get_used_cells():
		var item := get_cell_item(cell)
		
		if item != ceiling_light_item_id:
			continue

		var local_pos := map_to_local(cell) + light_offset
		var light := flicker_light_scene.instantiate()
		
		get_parent().add_child(light)

		light.global_position = to_global(local_pos)
		light.rotation.x = deg_to_rad(-90)

		
