# Author: @sanyabeast
# Date: Mar. 2024

@icon("res://assets/_dev/_icons/creature_1.png")
extends Node

class_name GNpcDriver
var TAG: String = "NpcDriver"

#region: Base NPC state class
class GNpcState:
	var driver: GNpcDriver
	var walk_power: float = 0
	var walk_angle: float = 0
	var look_angle: float = 0
	var is_firing: bool = false
	
	func _init(_driver: GNpcDriver):
		driver = _driver
	
	func update(character: GCharacterController, delta: float):
		pass
		
#endregion
		
var _states: Dictionary

func get_state(character: GCharacterController) -> GNpcState:
	if not _states.has(character):
		_create_state(character)
	return _states[character]

func _create_state(character: GCharacterController):
	_states[character] = GNpcState.new(self)

func update(character: GCharacterController, delta: float):
	pass

func update_physics(character: GCharacterController, delta: float):
	pass
