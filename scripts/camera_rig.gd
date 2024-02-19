extends Node3D

class_name S2CameraRig

var zoom: float = 0.7
var target_zoom: float = 0.25
var zoom_change_speed: float = 1
var zoom_step: float = 0.1

var close_look_angle: float = 60
var close_look_fov: float = 45
var close_look_elevation: float = 4
var close_root_elevation: float = 0

var far_look_angle: float = 0
var far_look_fov: float = 15
var far_look_elevation: float = 32
var far_root_elevation: float = 0

@onready var camera_root: Node3D = $CameraRoot
@onready var camera_node: Camera3D = $CameraRoot/Camera3D


# Called when the node enters the scene tree for the first time.
func _ready():
	print("camera rig: ready...")
	camera.add_camera(self)
	pass # Replace with function body.

func _exit_tree():
	camera.remove_camera(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	zoom = move_toward(zoom, target_zoom, zoom_change_speed * delta)
	
	if Input.is_action_just_pressed("camera_zoom_in"):
		target_zoom = zoom + zoom_step
	elif Input.is_action_just_pressed("camera_zoom_out"):
		target_zoom = zoom - zoom_step
		
	target_zoom = clampf(target_zoom, 0., 1.)
	
	var zoom_curve = zoom
	
	camera_node.position.y = lerpf(close_look_elevation, far_look_elevation, zoom_curve)
	camera_node.fov = lerpf(close_look_fov, far_look_fov, zoom_curve)
	
	camera_root.rotation_degrees.x = lerpf(close_look_angle, far_look_angle, zoom_curve)
	camera_root.position.y = lerpf(close_root_elevation, far_root_elevation, zoom_curve)

