extends GNpcDriver
class_name GNpcDriverBasicGameDude

#region: State Container
class GDudeState extends GNpcDriver.GNpcState:
	
	var target_position: Vector3 = Vector3(0, 0, 0)
	var is_wanna_move_to_target_position: bool = false
	var target_desired_distance_min: float = 0
	var target_desired_distance_max: float = 1
	var target_desired_distance_avg: float = 0.5
	var cooldowns: GCooldowns = GCooldowns.new(true)
	var target_walk_power: float = 0
	var target_walk_angle: float = 0
	var target_look_angle: float = 0
	var sin_offset: float = randf_range(0, PI)
	
	var current_distance_to_target_position: float = 0
	
	func update(character: GCharacterController, delta: float):
		_update_values(character, delta)
		
		if character.is_friendly:
			pass
		else:
			_update_enemy_state(character, delta)
		
	func _update_values(character: GCharacterController, delta: float):
		if character.has_weapon:
			target_desired_distance_min = character.weapon.config.ideal_distance_min
			target_desired_distance_max = character.weapon.config.ideal_distance_max
			target_desired_distance_avg = lerpf(target_desired_distance_min, target_desired_distance_max, 0.5)
		
		current_distance_to_target_position = character.global_position.distance_to(target_position)
		
		look_angle = tools.move_toward_deg(
			look_angle,
			target_look_angle,
			character.config.walk_direction_degrees_change_speed * delta
		)

		walk_angle = tools.move_toward_deg(
			walk_angle,
			target_walk_angle,
			character.config.walk_direction_degrees_change_speed * delta
		)

		walk_power = move_toward(
			walk_power, target_walk_power, character.config.walk_power_change_speed * delta
		)
			
	func _update_enemy_state(character: GCharacterController, delta: float):
		var nav_agent: NavigationAgent3D = character.nav_agent
		var walk_power: float = 0
		var walk_direction: Vector3 = Vector3.ZERO
		
		is_firing = false

		if (
			cooldowns.ready("update_target_position", true)
			or character.config.target_position_refresh_timeout <= 0
		):
			if characters.player != null:
				target_position = characters.player.global_position
			else:
				target_position = world.get_random_reachable_point_in_square(
					character.global_position, character.config.patrolling_distance
				)

			if character.config.target_position_refresh_timeout > 0:
				cooldowns.start(
					"update_target_position", character.config.target_position_refresh_timeout
				)

		nav_agent.target_position = target_position

		if current_distance_to_target_position > target_desired_distance_avg:
			walk_power = 1
			var next_path_position: Vector3 = nav_agent.get_next_path_position()
			walk_direction = character.global_position.direction_to(next_path_position)
			
		if  current_distance_to_target_position < target_desired_distance_max:
			target_look_angle = tools.rotation_degrees_y_from_direction_v2(
				tools.restrict_to_8_axis(
					tools.to_v2(character.global_position.direction_to(target_position))
				)
			)
			
			is_firing = true
			#character.look_direction = character.global_position.direction_to(target_position)
				
		target_walk_power = lerpf(
			character.config.walk_power_sinus_min_power,
			walk_power,
			(sin((game.time + sin_offset) * character.config.walk_power_sinus_rate) + 1) / 2
		)
		
		target_walk_angle = tools.rotation_degrees_y_from_direction_v2(
			tools.restrict_to_8_axis(tools.to_v2(Vector3(walk_direction.x, 0, walk_direction.z)))
		)

		target_walk_angle += (
			sin((game.time + sin_offset) * character.config.walk_direction_sinus_rate)
			* (45 * character.config.walk_direction_sinus_power)
		)

		pass
	
	func is_desired_distance_to_target_reached(character: GCharacterController) -> bool:
		return tools.is_in_range(
			current_distance_to_target_position,
			target_desired_distance_min,
			target_desired_distance_max
		)
	
	func handle_ai_disabled(character: GCharacterController):
		stop(character)
	
	func stop(character: GCharacterController):
		target_walk_power = 0
		walk_power = target_walk_power
		target_walk_angle = walk_angle
		target_look_angle = look_angle
		
#endregion

func _init():
	TAG = "NpcDriverBasicGameDude"

func _create_state(character: GCharacterController):
	_states[character] = GDudeState.new(self)

#region: State update
func update(character: GCharacterController, delta: float):
	var state = get_state(character)
	if not character.is_dead:
		state.update(character, delta)
#endregion

#region: Update actions
func update_physics(character: GCharacterController, delta: float):
	var state = get_state(character)
	
	if game.paused or not characters.ai_enabled or not character.ai_enabled:
		character.set_walk_power(0)
	else:
		character.set_walk_power(state.walk_power)
		character.set_look_direction(tools.angle_to_direction_v2(state.look_angle))
		character.set_walk_direction(tools.angle_to_direction_v2(state.walk_angle))
		
		if state.is_firing:
			character.fire()
		
#endregion
