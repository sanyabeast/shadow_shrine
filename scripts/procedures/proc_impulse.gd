extends GProcedure

@export var min_impulse: float = 1
@export var max_impulse: float = 1

func _start():
	world.commit_impulse(target, direction, randf_range(min_impulse, max_impulse))
