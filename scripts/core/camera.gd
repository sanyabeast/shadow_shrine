# Author: @sanyabeast
# Date: Feb. 2024

extends Node

class_name CameraManager

var current: S2CameraRig
var target_node: Node3D
var speed_dependent_behaviour: bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	print("camera manager: ready...")
	pass # Replace with function body.

func add_camera(camera: S2CameraRig):
	set_active_camera(camera)

func remove_camera(camera: S2CameraRig):
	if current == camera:
		unset_active_camera()
	
func set_active_camera(camera: S2CameraRig):
	current = camera

func unset_active_camera():
	current = null
	

func _process(delta):
	if current != null:
		if target_node != null:
			#current.global_position = current.global_position.lerp(target_node.global_position, 0.05)
			current.global_position = target_node.global_position
	pass
	
	if camera_manager.target_node == null and player_manager.current != null:
		camera_manager.target_node = player_manager.current
		
func get_camera3d():
	return get_viewport().get_camera_3d()
