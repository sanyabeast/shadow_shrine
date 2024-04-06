# Author: @sanyabeast
# Date: Apr. 2024

extends GTalent
class_name GWalkingTalent

@export var max_speed = 5

var angle: float = 0
var power: float = 0
var _direction:= Vector3.ZERO

func _ready():
	id = "walking"
	super._ready()

func set_power(_power: float = 0):
	power = _power
	
func set_angle(_angle: float = 0):
	angle = _angle
	_direction = tools.angle_to_direction(angle)

func _update_state(delta):
	pass

func _update_physics(delta):
	pass
