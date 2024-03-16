# Author: @sanyabeast
# Date: Feb. 2024

extends Node
class_name GCharacterNpcController
const TAG: String = "CharacterNpcController"

var character: GCharacterController
var nav_agent: NavigationAgent3D

var target_position: Vector3 = Vector3(0, 0, 0)
var is_wanna_move_to_target_position: bool = false
var target_desired_distance: float = 2

var cooldowns: GCooldowns = GCooldowns.new(true)

var _current_walk_power: float = 0
var _target_walk_power: float = 0

var _current_walk_direction_angle: float = 0
var _target_walk_direction_angle: float = 0

var _current_look_direction_angle: float = 0
var _target_look_direction_angle: float = 0

var _sinus_offset: float = randf_range(0, PI)

func update(delta):
	if character != null:
		if game.ai_enabled and character.ai_enabled:
			if not character.is_dead:
				if character.is_friendly:
					_update_friendly(delta)
				else:
					_update_enemy(delta)
				pass
		else:
			_target_walk_power = 0
			_target_walk_direction_angle = _current_walk_direction_angle
			_target_look_direction_angle = _current_look_direction_angle
			
		_update_movement(delta)
	
func initialize(_character: GCharacterController):
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
		if player_manager.current != null:
			target_position = player_manager.current.global_position
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
		#character.look_direction = character.global_position.direction_to(target_position)
		_target_look_direction_angle = tools.rotation_degrees_y_from_direction_v2(
			 tools.restrict_to_8_axis(tools.to_v2(character.global_position.direction_to(target_position)))
		)
	
	_target_walk_power = lerpf(
		character.config.walk_power_sinus_min_power,
		walk_power,
		(sin((game.time + _sinus_offset) * character.config.walk_power_sinus_rate) + 1) / 2
	)
	_target_walk_direction_angle = tools.rotation_degrees_y_from_direction_v2(
		 tools.restrict_to_8_axis(tools.to_v2(Vector3(walk_direction.x, 0, walk_direction.z)))
	)
	
	_target_walk_direction_angle += (sin((game.time + _sinus_offset) * character.config.walk_direction_sinus_rate) * (45 * character.config.walk_direction_sinus_power))
	
	pass

func _update_movement(delta):
	_current_look_direction_angle = tools.move_toward_deg(
		_current_look_direction_angle,
		_target_look_direction_angle,
		character.config.walk_direction_degrees_change_speed * delta
	)
	
	_current_walk_direction_angle = tools.move_toward_deg(
		_current_walk_direction_angle,
		_target_walk_direction_angle,
		character.config.walk_direction_degrees_change_speed * delta
	)
	
	_current_walk_power = move_toward(
		_current_walk_power,
		_target_walk_power,
		character.config.walk_power_change_speed * delta
	)
	
	character.set_walk_power(_current_walk_power)
	character.set_look_direction(
		tools.angle_to_direction_v2(_current_look_direction_angle)
	)
	character.set_walk_direction(
		tools.angle_to_direction_v2(_current_walk_direction_angle)
	)
