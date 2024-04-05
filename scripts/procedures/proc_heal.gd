# Author: @sanyabeast
# Date: Mar. 2024

extends GProcedure
class_name GHealProcedure

@export var amount: float = 1

func _start():
	if target is GTopDownCharacterController:
		target.commit_heal(amount * power)
