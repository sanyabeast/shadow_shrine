# Author: @sanyabeast
# Date: Feb. 2024

extends Node
class_name GWorldManager
const TAG: String = "WorldManager"

signal on_level_changed(from_scene, to_scene)

enum EDirection {
	North,
	East,
	South,
	West
}

var directions_list: Array[EDirection] = [EDirection.North, EDirection.East, EDirection.South, EDirection.West]
var sandbox: Node3D

# fx
var fx_queue: Array[Array] = []
var use_fx_pool: bool = true
var fx_pool: GPoolHelper = GPoolHelper.new(10)

var level_scene: Node3D = null

func _process(delta):
	_update_level_scene(delta)
	_update_fx_queue()
	dev.print_screen("World_fx_pool_size", "fx pool size: %s" % fx_pool.size())
	dev.print_screen("World_fx_pool_dict_size", "fx pool dictionary size: %s" % fx_pool.dictionary_size)
	dev.print_screen("World_fx_pool_overflow_stat", "fx pool overflow stat: %s" % fx_pool.overflow_stat)

func _update_level_scene(delta):
	var current_scene = get_tree().current_scene
	if current_scene != level_scene:
		dev.logd(TAG, "scene changed from %s to %s" % [current_scene, level_scene])
		on_level_changed.emit(current_scene, level_scene)
		_clear_pools()
		level_scene = current_scene
#endregion

#region FX
func spawn_fx(fx_config: RFXConfig, position: Vector3 = Vector3.ZERO, bound_object: Node3D = null, rotation = null):
	fx_queue.append([
		fx_config,
		position,
		bound_object,
		rotation
	])
	pass

func _spawn_fx_main(params: Array):
	var fx_config: RFXConfig = params[0]
	var position = params[1]
	var bound_object = params[2]
	var rotation = params[3]
	
	print("spawn fx: %s" % fx_config.resource_path)
	
	var fx_node: GFXController = fx_pool.pull(fx_config.resource_path)
	
	if fx_node == null:
		fx_node = GFXController.new(fx_config)
	else:
		fx_node.restruct()
	
	fx_node.bound_object = bound_object
	add_to_sandbox(fx_node)
	fx_node.global_position = position
	if rotation is Vector3:
		fx_node.rotation = rotation
		
	fx_node.start()
	
func _update_fx_queue():
	if fx_queue.size() > 0:
		var fx_params = fx_queue.pop_front()
		_spawn_fx_main(fx_params)
		
#endregion
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
	
#region: Navigation		
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
#ednregion

#region: Scenes and objects
func get_scene() -> Node3D:
	return tools.get_scene()

func reload():
	tools.load_scene(get_tree().current_scene.scene_file_path)
	#tools.reload_scene()e
		
func add_to_sandbox(object: Node):
	if sandbox != null:
		sandbox.add_child(object)
	else:
		add_to_level(object)
		
func add_to_level(object: Node):
	var scene = get_scene()
	if scene != null:
		scene.add_child(object)
	else:
		dev.logr(TAG, "get_scene returned null")
			
func set_sandbox(node: Node3D):
	sandbox = node

func _clear_pools():
	dev.logd(TAG, "clearing pools")
	fx_pool.clear()
#endregion
