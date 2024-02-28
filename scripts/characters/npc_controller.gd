extends Node

class_name S2NPCController

const TAG: String = "NPCController"

var character: S2Character
var nav_agent: NavigationAgent3D

var target_position: Vector3 = Vector3(0, 0, 0)
var is_wanna_move_to_target_position: bool = false
var target_desired_distance: float = 0

var cooldowns: S2CooldownManager = S2CooldownManager.new(true)

func update(delta):
	if character != null:
		if character.is_friendly:
			_update_friendly(delta)
		else:
			_update_enemy(delta)
		pass
	pass

func initialize(_character: S2Character):
	character = _character
	nav_agent = NavigationAgent3D.new()
	
	nav_agent.target_position = character.global_position
	character.add_child(nav_agent)

func _update_friendly(delta):
	var walk_power: float = 0
	var walk_direction: Vector3 = Vector3.ZERO
	
	if nav_agent.is_target_reached():
		var target_position = world.get_random_reachable_point_in_square(character.global_position, character.config.patrolling_distance)
		nav_agent.target_position = target_position
		nav_agent.target_desired_distance = target_desired_distance
	else:
		var next_path_position: Vector3 = nav_agent.get_next_path_position()
		walk_power = 1
		walk_direction = character.global_position.direction_to(next_path_position)
		pass
	pass
	
	character.walk_power = walk_power
	character.walk_direction = walk_direction
	
func _update_enemy(delta):
	var walk_power: float = 0
	var walk_direction: Vector3 = Vector3.ZERO
	
	if cooldowns.ready("update_target_position", true) or character.config.target_position_refresh_timeout <= 0:
		if player.current != null:
			target_position = player.current.global_position
		else:
			target_position = world.get_random_reachable_point_in_square(character.global_position, character.config.patrolling_distance)
		
		if character.config.target_position_refresh_timeout > 0:
			cooldowns.start("update_target_position", character.config.target_position_refresh_timeout)
	
	nav_agent.target_position = target_position
	nav_agent.target_desired_distance = target_desired_distance	
	
	if not nav_agent.is_target_reached():
		walk_power = 1
		var next_path_position: Vector3 = nav_agent.get_next_path_position()
		walk_direction = character.global_position.direction_to(next_path_position)
	else:
		character.look_direction = character.global_position.direction_to(target_position)
	
	character.walk_power = walk_power
	character.walk_direction = Vector3(walk_direction.x, 0, walk_direction.z)
	pass
