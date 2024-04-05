# Author: @sanyabeast
# Date: Mar. 2024

extends GProcedure
class_name GDamageProcedure

@export var min_damage: float = 1
@export var max_damage: float = 1

func _start() -> bool:
	if target is GCharacterController:
		return target.commit_damage(randf_range(min_damage, max_damage), position, direction)
	return false
