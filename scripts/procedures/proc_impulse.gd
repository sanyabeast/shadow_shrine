# Author: @sanyabeast
# Date: Mar. 2024

extends GProcedure
class_name GImpulseProcedure

@export var min_impulse: float = 1
@export var max_impulse: float = 1

func _start() -> bool:
	world.commit_impulse(target, direction, randf_range(min_impulse, max_impulse))
	return true
