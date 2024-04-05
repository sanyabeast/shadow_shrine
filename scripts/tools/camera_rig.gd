# Author: @sanyabeast
# Date: Feb. 2024

@icon("res://assets/_dev/_icons/camera_a.png")
extends Node3D

class_name GCameraController
var TAG: String = "CameraController"

static var instance: GCameraController

var zoom: float = 1
var target_zoom: float = 0.5
var zoom_change_speed: float = 0.1
var zoom_step: float = 0.1

var close_look_angle: float = 40
var close_look_fov: float = 45
var close_look_elevation: float = 8
var close_root_elevation: float = 0

var far_look_angle: float = 35
var far_look_fov: float = 25
var far_look_elevation: float = 18
var far_root_elevation: float = 0

@export_subgroup("# Camera Controller")
@onready var camera_root: Node3D = $CameraRoot
@onready var camera: Camera3D = $CameraRoot/Camera3D

@export_subgroup("# Camera Controller - Spotlight")
@export var spotlight_enabled: bool = false
@export var spotlight: SpotLight3D
@export var spotlight_move_speed: float = 5
var _spotlight_position: Vector3 


# Called when the node enters the scene tree for the first time.
func _ready():
	instance = self
	
	if spotlight_enabled and spotlight:
		_spotlight_position = spotlight.global_position
		
	camera_manager.target_camera = camera	
		
func _enter_tree():
	camera_manager.target_camera = camera
	
func _exit_tree():
	if camera_manager.target_camera == camera:
		camera_manager.target_camera = null
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#zoom = move_toward(zoom, target_zoom, zoom_change_speed * delta)
	zoom = lerpf(zoom, target_zoom, 0.0025)
	
	if Input.is_action_just_pressed("camera_zoom_in"):
		target_zoom = zoom + zoom_step
	elif Input.is_action_just_pressed("camera_zoom_out"):
		target_zoom = zoom - zoom_step
		
	target_zoom = clampf(target_zoom, 0., 1.)
	
	var zoom_curve = zoom
	
	camera.position.y = lerpf(close_look_elevation, far_look_elevation, zoom_curve)
	camera.fov = lerpf(close_look_fov, far_look_fov, zoom_curve)
	
	camera_root.rotation_degrees.x = lerpf(close_look_angle, far_look_angle, zoom_curve)
	camera_root.position.y = lerpf(close_root_elevation, far_root_elevation, zoom_curve)
	
	if spotlight_enabled:
		#_spotlight_position = _spotlight_position.move_toward(Vector3(global_position.x, _spotlight_position.y, global_position.z), spotlight_move_speed * delta)
		_spotlight_position = _spotlight_position.lerp(Vector3(global_position.x, _spotlight_position.y, global_position.z), 0.01)
		spotlight.global_position = _spotlight_position

	if characters.player != null:
		global_position = Vector3(
			characters.player.global_position.x,
			0,
			characters.player.global_position.z,
		)

func _physics_process(delta):
	pass
	
