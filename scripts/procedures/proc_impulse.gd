extends GProcedure

@export var min_impulse: float = 1
@export var max_impulse: float = 1

func _start():
	if target is GCharacterController:
		target.commit_impulse(direction, randf_range(min_impulse, max_impulse))
