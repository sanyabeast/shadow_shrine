# Author: @sanyabeast
# Date: Mar. 2024

# This script defines a LosServer class for managing Line of Sight (LOS) tasks in a 3D environment.

class_name GLosServer

# Tag for logging.
const TAG: String = "LosServer"

# Represents a LOS task between two 3D nodes.
class GLosTask:
	var source: Node3D
	var target: Node3D
	var has_los: bool = false
	
	# Initializes a new LOS task with source and target nodes.
	func _init(_s: Node3D, _t: Node3D):
		source = _s
		target = _t
	
	# Checks if the LOS task is valid.
	func is_valid() -> bool:
		return source != null and target != null and source.is_visible_in_tree() and target.is_visible_in_tree() and source.is_inside_tree() and target.is_inside_tree()
	
	# Returns a string representation of the LOS task.
	func _to_string():
		return "GLosTask(source: %s, target: %s, has_los: %s)" % [source, target, has_los]

# Update rate for LOS checks.
var update_rate:= 15.0
# Elevation of the LOS test ray.
var ray_elevation: float = 0.5

# Dictionary to store LOS tasks.
var _los_tasks: Dictionary
# Time gate helper for controlling update frequency.
var _time_gate:= GTimeGateHelper.new(true)
# Index of the current LOS test.
var _current_los_test_index: int = 0
# RayCast3D node for LOS testing.
var _los_test_ray: RayCast3D

# Checks if there is LOS between the source and target nodes.
func has_los(source: Node3D, target: Node3D) -> bool:
	var id:= _get_los_id(source, target)
	var task: GLosTask
	if not _los_tasks.has(id):
		task = GLosTask.new(source, target)
		_los_tasks[id] = task
	else:
		task = _los_tasks[id]
	
	return task.has_los

# Called every frame. 'delta' is the elapsed time since the previous frame.
func update(delta):
	if _time_gate.check("check_los", 1. / update_rate):
		if _los_tasks.keys().size() > 0:
			_update_los(_current_los_test_index)
		else:
			dev.logd(TAG, "no los tasks")
	pass
	
	dev.print_screen("los_tasks_count", "los tasks count: %s" % _los_tasks.keys().size())

# Generates a unique ID for an LOS task based on source and target nodes.
func _get_los_id(source: Node3D, target: Node3D) -> String:
	return str(source.get_instance_id()) + "_" + str(target.get_instance_id())

# Updates the LOS test for a given key index.
func _update_los(key_index: int):
	
	key_index = key_index % _los_tasks.keys().size()
	dev.logd(TAG, "updating los %s/%s" % [key_index, _los_tasks.keys()])
	var key: String = _los_tasks.keys()[key_index]
	var task: GLosTask = _los_tasks[key]
	
	if not task.is_valid():
		_los_tasks.erase(key)
		return
	
	_check_ray()
	
	_los_test_ray.global_position = task.source.global_position
	_los_test_ray.target_position = _los_test_ray.to_local(task.target.global_position) 
	
	_los_test_ray.global_position.y = ray_elevation
	_los_test_ray.target_position.y = ray_elevation
	
	_los_test_ray.force_raycast_update()
	task.has_los = not _los_test_ray.is_colliding()
	
	print("updated los: %s" % task)
	
	_current_los_test_index = (_current_los_test_index + 1) % _los_tasks.keys().size()
	pass

# Checks the availability of the LOS test ray and initializes it if necessary.
func _check_ray():
	if _los_test_ray == null:
		_los_test_ray = RayCast3D.new()
		_los_test_ray.collide_with_bodies = true
		
		_los_test_ray.set_collision_mask_value(world.ECollisionBodyType.Static, true)
		_los_test_ray.set_collision_mask_value(world.ECollisionBodyType.Character, false)
		_los_test_ray.set_collision_mask_value(world.ECollisionBodyType.Projectile, false)
		_los_test_ray.set_collision_mask_value(world.ECollisionBodyType.Area, false)
		
		world.add_to_level(_los_test_ray)
