# Author: @sanyabeast
# Date: Feb. 2024

extends Node
class_name GCameraManager
const TAG: String = "CameraManager"

var camera: Camera3D
var target_camera: Camera3D

func _process(delta):
	_check_camera()
	#_update_target_camera(delta)
	
func _physics_process(delta):
	pass
	_update_target_camera(delta)
		
func _check_camera():
	if camera == null and world.level_scene != null:
		camera = Camera3D.new()
		camera.name = "MainCamera"
		world.add_to_level(camera)
		camera.make_current()
		camera.global_position = Vector3(0, 8, 0)
		camera.global_rotation_degrees.x = -90
		#camera.global_rotation_degrees.z = 180
		
	if camera != null and not camera.current:
		camera.make_current()

func _update_target_camera(delta):
	if camera != null and target_camera != null:
		camera.fov = target_camera.fov
		#camera.global_position = target_camera.global_position
		#camera.global_rotation = target_camera.global_rotation
		
		camera.global_position = camera.global_position.lerp(target_camera.global_position, 0.1) 
		camera.global_rotation = target_camera.global_rotation
		
		#camera.global_position = camera.global_position.move_toward(target_camera.global_position, 16 * delta) 
		#camera.global_rotation = target_camera.global_rotation
	
		
func get_camera3d():
	return camera
