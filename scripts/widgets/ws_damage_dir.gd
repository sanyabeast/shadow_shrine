extends ColorRect
class_name GDamageDirectionIndicator
const TAG: String = "DamageDirectionIndicator"

@export var fade_time: float = 3;

@export var direction_n: float = 0.;
@export var direction_ne: float = 0.;
@export var direction_e: float = 0.;
@export var direction_se: float = 0.;
@export var direction_s: float = 0.;
@export var direction_sw: float = 0.;
@export var direction_w: float = 0.;
@export var direction_nw: float = 0.;

var _material: ShaderMaterial
var _time_gate: = GTimeGateHelper.new(true)

# Called when the node enters the scene tree for the first time.
func _ready():
	_material = material
	characters.on_player_hurt.connect(_handle_player_hurt)
	pass # Replace with function body.

func _handle_player_hurt(health_loss: float, point:= Vector3.ZERO, direction:= Vector3.ZERO):
	var dir: Vector2 = tools.restrict_to_8_axis(tools.to_v2(direction))
	var angle: int =  -tools.rotation_degrees_y_from_direction_v2(dir)
	if angle < 0:
		angle = 360 + angle
	
	angle += 270
	
	angle = angle % 360
	
	match angle:
		270:
			direction_n = 1
		90: 
			direction_s = 1
		180:
			direction_w = 1
		0:
			direction_e = 1
		360:
			direction_s = 1
		45:
			direction_se = 1
		135:
			direction_sw = 1
		225:
			direction_nw = 1
		315:
			direction_ne = 1
	
	#dev.logd(TAG, "player hurt: health loss: %s, direction v3: %s, angle: %s" % [health_loss, direction, angle])
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#if _time_gate.check("test", 1):
		#if characters.player != null:
			#_handle_player_hurt(1, Vector3.ZERO, -characters.player.look_direction)
	
	_update_fade(delta)
	_update_shader()
	pass

func _update_fade(delta):
	direction_n = move_toward(direction_n, 0., (1. / fade_time) * delta)
	direction_ne = move_toward(direction_ne, 0., (1. / fade_time) * delta)
	direction_e = move_toward(direction_e, 0., (1. / fade_time) * delta)
	direction_se = move_toward(direction_se, 0., (1. / fade_time) * delta)
	direction_s = move_toward(direction_s, 0., (1. / fade_time) * delta)
	direction_sw = move_toward(direction_sw, 0., (1. / fade_time) * delta)
	direction_w = move_toward(direction_w, 0., (1. / fade_time) * delta)
	direction_nw = move_toward(direction_nw, 0., (1. / fade_time) * delta)

func _update_shader():
	_material.set_shader_parameter("direction_n", direction_n)
	_material.set_shader_parameter("direction_ne", direction_ne)
	_material.set_shader_parameter("direction_e", direction_e)
	_material.set_shader_parameter("direction_se", direction_se)
	_material.set_shader_parameter("direction_s", direction_s)
	_material.set_shader_parameter("direction_sw", direction_sw)
	_material.set_shader_parameter("direction_w", direction_w)
	_material.set_shader_parameter("direction_nw", direction_nw)
