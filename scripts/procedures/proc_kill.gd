# Author: @sanyabeast
# Date: Apr. 2024

extends GProcedure
class_name GKillProcedure

func _start():
	if target is GCharacterController:
		print("KILLING %s" % GCharacterController)
		target.die()
