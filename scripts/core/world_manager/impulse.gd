# Author: @sanyabeast
# Date: Mar. 2024

class_name GImpulse

var target: Node3D
var direction:= Vector3.ZERO
var power:= 0.0

static func is_applicable(target: Node3D) -> bool:
	if target == null:
		return false
		
	if target is GCharacterController:
		if target.is_unshakable:
			return false
		elif characters.is_player(target) and characters.force_player_unshakable:
			return false
		else:
			return true
		
	if target is CharacterBody3D:
		return true
	
	return false

var is_valid: bool:
	get:
		return target != null and target.is_inside_tree()
var is_finished: bool:
	get:
		return power <= 0.0
		
func _init(_t: Node3D, _d:= Vector3.ZERO, _p:= 1.0):
	target = _t
	power = _p
	direction = _d.normalized()
	
func update(delta):
	power = move_toward(power, 0.0, 2.0 * delta)
	
func add(_d:= Vector3.ZERO, _p:= 1.0):
	power = max(power, _p)
	#direction = (direction + _d).normalized()
	direction  = _d

func apply():
	if target is GCharacterController:
		target.impulse_power = power
		target.impulse_direction = direction
	pass
