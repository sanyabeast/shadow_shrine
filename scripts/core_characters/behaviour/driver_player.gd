# Author: @sanyabeast
# Date: Mar. 2024

@icon("res://assets/_dev/_icons/dotto-emoji-main-svg/Dotto Emoji73.svg")
extends Node

class_name GPlayerDriver
const TAG: String = "PlayerDriver"

func update(player: GTopDownCharacterController, delta: float):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var walk_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var look_input = Input.get_vector("shoot_left", "shoot_right", "shoot_up", "shoot_down")
	
	walk_input = tools.restrict_to_8_axis(walk_input)
	look_input = tools.restrict_to_8_axis(look_input)
	
	player.set_walk_power(round(walk_input.length()))
	player.set_walk_direction(walk_input.normalized())
	player.set_look_direction(look_input.normalized())
	
	if look_input.length() > 0.1:
		player.fire()
