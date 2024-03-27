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

enum ECollisionBodyType {
	Static = 1,
	Character = 2,
	Projectile = 3,
	Area = 4
}

var directions_list: Array[EDirection] = [EDirection.North, EDirection.East, EDirection.South, EDirection.West]
var sandbox: Node3D

# fx
var fx_queue: Array[Array] = []
var use_fx_pool: bool = true
var fx_pool: GPoolHelper = GPoolHelper.new(16)

var use_projectile_pool: bool = true
var projectile_pool: GPoolHelper = GPoolHelper.new(8)
var level_scene: Node = null
var los_server:= GLosServer.new()
var _impulses: Dictionary = {}

func _process(delta):
	_update_level_scene(delta)
	_update_fx_queue()
		
	if tools.IS_DEBUG:
		dev.print_screen("world_fx_pool_stats", "fx pool (size / dict / overflow): %s / %s / %s" % [
			fx_pool.size(),
			fx_pool.dictionary_size,
			fx_pool.overflow_stat
		])
		
		dev.print_screen("world_projectile_pool_stats", "projectile pool (size / dict / overflow):  %s / %s / %s" % [
			projectile_pool.size(),
			projectile_pool.dictionary_size,
			projectile_pool.overflow_stat
		])
		
		dev.print_screen("world_impulses_tasks", "active impulses: %s" % [_impulses.keys().size()])
	
func _physics_process(delta):
	los_server.update(delta)
	_update_impulses(delta)
	
func _update_level_scene(delta):
	var current_scene = get_tree().current_scene
	if current_scene != level_scene:
		dev.logd(TAG, "scene changed from %s to %s" % [level_scene, current_scene])
		on_level_changed.emit(current_scene, level_scene)
		_clear_pools()
		level_scene = current_scene
#endregion

#region FX
func spawn_fx(fx_config: RFXConfig, position: Vector3 = Vector3.ZERO, bound_object: Node3D = null, rotation = null):
	_spawn_fx_main(fx_config, position, bound_object, rotation)

func _spawn_fx_main(fx_config: RFXConfig, position: Vector3 = Vector3.ZERO, bound_object: Node3D = null, rotation = null):
	var fx_node: GFXController = fx_pool.pull(fx_config.resource_path)
	
	if fx_node == null:
		fx_node = GFXController.new(fx_config)
	else:
		fx_node.reborn()
	
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
	projectile_pool.clear()
#endregion

#region: Impulses
func commit_impulse(target: Node3D, direction: Vector3, power: float):
	if GImpulse.is_applicable(target):
		var impulse_data: GImpulse
		if _impulses.has(target):
			impulse_data = _impulses[target]
			impulse_data.add(direction, power,)
		else:
			impulse_data = GImpulse.new(target, direction, power)
			_impulses[target] = impulse_data

func _update_impulses(delta: float):
	for key in _impulses.keys():
		var impulse_data: GImpulse = _impulses[key]
		if not impulse_data.is_valid or impulse_data.is_finished:
			_impulses.erase(key)
		else:
			impulse_data.update(delta)
			impulse_data.apply()
