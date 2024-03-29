# Author: @sanyabeast
# Date: Feb. 2024


@icon("res://assets/_dev/_icons/dotto-emoji-main-svg/Dotto Emoji181.svg")
extends GPUParticles3D
class_name GParticlesHelper3D
const TAG: String = "ParticlesHelper3D"

enum EPositioningMode {
	TwoDimensional,
	ThreeDimensional,
	LookAt
}

@export_subgroup("# ParticlesHelper3D ~ Velocity to Amount")
@export var use_velocity_to_amount: bool = false
@export var velocity_to_amount_min_amount: float = 0
@export var velocity_to_amount_max_amount: float = 1
@export var velocity_to_amount_max_velocity: float = 2
@export var velocity_to_amount_curve: float = 1.5

@export_subgroup("# ParticlesHelper3D ~ Camera Space Positioning")
@export var use_camera_space_positioning:= false
@export var camera_space_positioning_mode:= EPositioningMode.TwoDimensional
@export var camera_space_positioning_offset:= Vector3.ZERO

@export_subgroup("# ParticlesHelper3D ~ Player Positioning")
@export var use_player_positioning:= false
@export var player_positioning_mode:= EPositioningMode.TwoDimensional
@export var player_positioning_offset:= Vector3.ZERO

@export_subgroup("# ParticlesHelper3D ~ Wind")
@export var use_wind_to_gravity: bool = false
@export var wind_to_gravity_strength: float = 1
@export var wind_to_gravity_update_rate: float = 5

var _direction: Vector3 = Vector3.ZERO
var _velocity: Vector3 = Vector3.ZERO
var _velocity_scalar: float = 0
var _velocity_progress: float = 0

var _prev_global_position: Vector3 = Vector3.ZERO
var _timer_gate: GTimeGateHelper = GTimeGateHelper.new(false)

# Called when the node enters the scene tree for the first time.
func _ready():
	_prev_global_position = global_position
	#if use_wind_to_gravity:
		#process_material = process_material.duplicate()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var position_delta: Vector3 = global_position - _prev_global_position
	_velocity = position_delta
	_velocity_scalar = position_delta.length()
	_direction = position_delta.normalized()
	_velocity_progress = clampf(_velocity_scalar / velocity_to_amount_max_velocity / delta, 0., 1.)	
	
	# updating things here
	if use_velocity_to_amount:
		amount_ratio = lerp(
			amount_ratio,
			lerpf(velocity_to_amount_min_amount, velocity_to_amount_max_amount, pow(_velocity_progress, velocity_to_amount_curve)),
			0.2
		)
		
	if use_camera_space_positioning:
		_update_camera_space_positioning(delta)
	
	if use_player_positioning:
		_update_player_positioning(delta)
	
	if use_wind_to_gravity and  _timer_gate.check("wtg_update", 1 / wind_to_gravity_update_rate):
		_update_wind_to_gravity(delta)
	
	# - - - - - - - 
	_prev_global_position = global_position
	pass

func _update_camera_space_positioning(delta: float):
	var camera3d: Camera3D = camera_manager.get_camera3d()
	if camera3d != null:
		match camera_space_positioning_mode:
			EPositioningMode.TwoDimensional:
				global_position.x = camera3d.global_position.x + camera_space_positioning_offset.x
				global_position.z = camera3d.global_position.z + camera_space_positioning_offset.z
			EPositioningMode.ThreeDimensional:
				global_position = camera3d.global_position + camera_space_positioning_offset
			EPositioningMode.LookAt:
				global_position = camera3d.global_position + camera_space_positioning_offset	
				basis.z = camera3d.basis.z
	pass

func _update_player_positioning(delta: float):
	var player: GCharacterController = characters.player
	
	if player != null:
		match camera_space_positioning_mode:
			EPositioningMode.TwoDimensional:
				global_position.x = player.global_position.x + camera_space_positioning_offset.x
				global_position.z = player.global_position.z + camera_space_positioning_offset.z
			EPositioningMode.ThreeDimensional:
				global_position = player.global_position + camera_space_positioning_offset
			EPositioningMode.LookAt:
				global_position = player.global_position + camera_space_positioning_offset	
				basis.z = player.basis.z
	pass

func _update_wind_to_gravity(delta):
	var mat: ParticleProcessMaterial = process_material
	var wind_dir: Vector2 = tools.angle_to_direction_v2(world.wind_direction)
	process_material.gravity.x = -wind_dir.x * wind_to_gravity_strength * world.wind_power
	process_material.gravity.z = -wind_dir.y * wind_to_gravity_strength * world.wind_power
