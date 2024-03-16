extends GProcedure

@export var min_damage: float = 1
@export var max_damage: float = 1

func _start():
	if target is GCharacterController:
		target.commit_damage(randf_range(min_damage, max_damage), position)
