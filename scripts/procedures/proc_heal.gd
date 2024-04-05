# Author: @sanyabeast
# Date: Mar. 2024

extends GProcedure
class_name GHealProcedure

@export var amount: float = 1

func _start() -> bool:
	if target is GTopDownCharacterController:
		return target.commit_heal(amount * power)
	else:
		return false
