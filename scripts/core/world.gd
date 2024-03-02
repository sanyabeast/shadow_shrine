extends Node

class_name S2WorldManager

enum EDirection {
	North,
	East,
	South,
	West
}

var directions_list: Array[EDirection] = [EDirection.North, EDirection.East, EDirection.South, EDirection.West]

# Called when the node enters the scene tree for the first time.
func _ready():
	print("world manager ready...")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

	
func get_oposite_direction(direcrion: EDirection) -> EDirection:
	match direcrion:
		EDirection.North:
			return EDirection.South
		EDirection.East:
			return EDirection.West
		EDirection.South:
			return EDirection.North
		EDirection.West:
			return EDirection.East
		_:
			return EDirection.East

func get_node_direction(node: Node3D) -> EDirection	:
	# Assuming the y-axis rotation represents the rotation around the vertical axis (up vector)
	var rotation_degrees = rad_to_deg(node.transform.basis.get_euler().y)
	var direction: EDirection = EDirection.North
	
	# Normalize the rotation to the range [0, 360)
	rotation_degrees = fmod(rotation_degrees + 360, 360)
	
	# Determine the direction based on the rotation
	if rotation_degrees < 45 or rotation_degrees >= 315:
		direction = EDirection.North
	elif rotation_degrees >= 45 and rotation_degrees < 135:
		direction = EDirection.West
	elif rotation_degrees >= 135 and rotation_degrees < 225:
		direction = EDirection.South
	elif rotation_degrees >= 225 and rotation_degrees < 315:
		direction = EDirection.East
		
	return direction

func get_direction_pretty_name(dir: EDirection) -> String:
	match dir:
		EDirection.North:
			return "North"
		EDirection.East:
			return "East"
		EDirection.South:
			return "South"
		EDirection.West:
			return "West"
	return "?"
	
	
func get_random_reachable_point_in_square(origin: Vector3, square_size: float):
	var random_point: Vector3 = Vector3(
		origin.x + randf_range(-square_size / 2, square_size / 2),
		origin.y + randf_range(-square_size / 2, square_size / 2),
		origin.z + randf_range(-square_size / 2, square_size / 2)
	)
	
	var reachable_point: Vector3 = get_closest_reachable_point(random_point)
	return reachable_point

func get_closest_reachable_point(point: Vector3)->Vector3:
	if NavigationServer3D.get_maps().size() > 0:
		return NavigationServer3D.map_get_closest_point(NavigationServer3D.get_maps()[0], point)
	else:
		return point

func get_scene() -> Node3D:
	return tools.get_scene()

func spawn_fx(fx_config: RFXConfig, position: Vector3 = Vector3.ZERO, bound_object: Node3D = null, rotation = null):
	var fx_node: S2FX = S2FX.new()
	fx_node.global_position = position
	if rotation is Vector3:
		fx_node.rotation = rotation
	fx_node.bound_object = bound_object
	fx_node.config = fx_config
	get_scene().add_child(fx_node)
	fx_node.start()
