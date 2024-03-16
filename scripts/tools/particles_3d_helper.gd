extends GPUParticles3D
class_name S2Particles3DHelper
const TAG: String = "Particles3DHelper"

@export_subgroup("Velocity to Amount")
@export var use_velocity_to_amount: bool = false
@export var velocity_to_amount_min_amount: float = 0
@export var velocity_to_amount_max_amount: float = 1
@export var velocity_to_amount_max_velocity: float = 2
@export var velocity_to_amount_curve: float = 1.5

var _direction: Vector3 = Vector3.ZERO
var _velocity: Vector3 = Vector3.ZERO
var _velocity_scalar: float = 0
var _velocity_progress: float = 0

var _prev_global_position: Vector3 = Vector3.ZERO
var _timer_gate: GTimeGateHelper = GTimeGateHelper.new(false)

# Called when the node enters the scene tree for the first time.
func _ready():
	_prev_global_position = global_position
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
	
	# - - - - - - - 
	_prev_global_position = global_position
	pass
