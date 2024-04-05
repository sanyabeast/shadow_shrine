# Author: @sanyabeast
# Date: Feb. 2024

extends Node
class_name GCharactersManager
var TAG: String = "CharactersManager"

signal on_player_dead
signal on_player_hurt(health_loss: float, point: Vector3, direction: Vector3)
signal on_player_alive
signal on_enemies_dead
signal on_enemies_alive
signal on_enemy_dead
signal on_enemy_alive

enum ECharacterVerticalMobilityMode {
	GRAVITY,
	LOCK_0
}

var player: GCharacterController
var player_character_id: String = ""
var player_invulnerable: bool = true
var player_incoming_impulse_scale: float = 0.2

var player_enabled: bool = false
var ai_enabled: bool = false

var player_driver: GPlayerDriver
var npc_driver: GNpcDriver

var list: Array[GCharacterController] = []
var alive_npc_count: int = 0
var alive_enemies_count: int = 0
var _player_prev_dead: bool = true

var is_enemy_friendly_fire_enabled: bool = true
var is_player_friendly_fire_enabled: bool = false

var force_player_invulnerable: bool = false
var force_player_immortal: bool = false

var last_player_position: Vector3 = Vector3.ZERO

var use_character_overlapping_impulse: bool = true
var _current_overlapping_impulse_test_character_index_a: int = 0
var _current_overlapping_impulse_test_character_index_b: int = 0

var vertical_mobility_mode:= ECharacterVerticalMobilityMode.LOCK_0

#region: Process
func _process(delta):
	if not game.paused:
		_update_npc(delta)
		_update_player(delta)
	
	if tools.IS_DEBUG:
		dev.print_screen("characters_stats", "characters: (total / enemies): %s / %s" % [list.size(), alive_enemies_count])
		dev.print_screen("player_state", "player (innvul. / immortal): %s / %s" % [force_player_invulnerable, force_player_immortal])
			
	if tools.is_node_active(player):
		last_player_position = player.global_position
		
func _physics_process(delta):
	if not game.paused:
		if  player_enabled and (player_driver != null) and (player != null) and (not player.is_dead):
			player_driver.update(player, delta)
		
		if npc_driver != null:
			for character in list:
				if not is_player(character):
					npc_driver.update_physics(character, delta)
					
		if use_character_overlapping_impulse:
			_update_character_overlapping_impulse(delta)			
					
		
#endregion

func _update_character_overlapping_impulse(delta):
	if list.size() > 1:
		_current_overlapping_impulse_test_character_index_a = _current_overlapping_impulse_test_character_index_a % list.size()
	
		var character_a = list[_current_overlapping_impulse_test_character_index_a]		
		
		if not character_a.is_dead:
			for character_b in list:
				if character_b != character_a:
					var distance = character_a.global_position.distance_to(character_b.global_position)
					
					if distance < character_b.config.body_radius + character_a.config.body_radius:
						var distance_ratio = distance / (character_b.config.body_radius + character_a.config.body_radius)
						world.commit_impulse(
							character_b, 
							character_a.global_position.direction_to(character_b.global_position), 
						4. * (1.0 - pow(distance_ratio, 2.)))
		
		_current_overlapping_impulse_test_character_index_a += 1

#region: Linking
func link(character: GCharacterController):
	dev.logd(TAG, "linking character: %s" % character.name)
	
	world.set_collision(character, world.ECollisionBodyType.Character, [
		#world.ECollisionBodyType.Character,
		world.ECollisionBodyType.Static,
		world.ECollisionBodyType.Projectile,
		world.ECollisionBodyType.Area
	])
	
	list.append(character)
	
func unlink(character: GCharacterController):
	dev.logd(TAG, "UNlinking character: %s" % character.name)
	var index = list.find(character)
	if index > -1:
		list.remove_at(index)
#endregion

#region: Drivers
func set_player_driver(driver: GPlayerDriver):
	dev.logd(TAG, "player driver set to %s" % driver)
	player_driver = driver

func set_npc_driver(driver: GNpcDriver):
	dev.logd(TAG, "npc driver set to %s" % driver)
	npc_driver = driver
	
func unset_drivers():
	player_driver = null
	npc_driver = null
	
#endregion

#region: Player management
func _update_player(delta):
	if player != null:
		if player.is_dead:
			if not _player_prev_dead:
				# players appears dead
				on_player_dead.emit()
		else:
			if _player_prev_dead:
				on_player_alive.emit()
				
		_player_prev_dead = player.is_dead
		
		#widgets.set_token("player_health", player.health.value)
		widgets.set_token("player_health", player.get_ability_value("health"))
		widgets.set_token("player_max_health", player.get_ability("health").max_value)
	
func set_player(character: GCharacterController):
	dev.logd(TAG, "active player set to: %s" % character)
	if player != null:
		player.on_hurt.disconnect(_handle_player_hurt)
		
	player = character
	player_character_id = character.id
	player.on_hurt.connect(_handle_player_hurt)

func is_player(character: GCharacterController) -> bool:
	return character == player

func teleport_player(position: Vector3, rotation = null):
	if player != null:
		player.global_position = position
		if rotation != null:
			player.global_rotation_degrees.y = rotation
	else:
		tools.logd(TAG, "no players to teleport")


func respawn_player(position: Vector3, look_angle: float = 0) -> GCharacterController:
	if player_character_id.length() > 0:
		return spawn_player(player_character_id, position, look_angle)
	else:
		dev.logd(TAG, "failed to respawn player:  `player_character_id` is empty")
	return null

func spawn_player(character_id: String, position: Vector3, look_angle: float = 0):
	var _player = spawn_character(world.get_scene(), character_id, position, look_angle)
	set_player(_player)

func spawn_character(parent_node: Node3D, character_id: String, position: Vector3, look_angle: float = 0) -> GCharacterController:
	var entry: GThesaurusEntry = game.thesaurus.get_entry("characters", character_id)
	var prefab = entry.main_scene
	var _character: GCharacterController = prefab.instantiate(3)
	_character.position = position
	parent_node.add_child(_character)
	_character.global_position = position
	_character.look_direction = tools.angle_to_direction(look_angle)
	return _character

func kill_player():
	if player != null:
		player.die()

func remove_player():
	if player != null:
		player.queue_free()

func enable_player(activate: bool = true):
	player_enabled = true
	if activate:
		activate_player()
	
func disable_player(deactivate: bool = false):
	player_enabled = false
	if deactivate:
		deactivate_player()
	
func activate_player():
	if player != null:
		player.active = true
	
func deactivate_player():
	if player != null:
		player.active = false
	
func _handle_player_hurt(health_loss: float, point:= Vector3.ZERO, direction:= Vector3.ZERO):
	on_player_hurt.emit(health_loss, point, direction)
#endregion

#region: NPC management
func enable_ai():
	dev.logd(TAG, "enabling npc ai")
	ai_enabled = true

func disable_ai():
	dev.logd(TAG, "disabling npc ai")
	ai_enabled = false
	if npc_driver != null:
		for character in list: 
			if not is_player(character):
				npc_driver.on_ai_disabled(character)

func is_enemy(character: GCharacterController) -> bool:
	return not is_player(character) and not character.is_friendly
	
func is_friend(character: GCharacterController) -> bool:
	return not is_player(character) and character.is_friendly
	
func kill_enemies(interval: float = 0):
	dev.logd(TAG, "killing all enemies...")
	for character in list:
		if not is_player(character) and not character.is_friendly:
			if interval == 0:
				character.die()
			else:
				game.tasks.queue(self, "kill-enemy", interval, null, character.die)
			#character.die()

func commit_damage_to_all_enemies(value: float):
	for character in list:
		if not is_player(character) and not character.is_friendly:
			character.commit_damage(value, character.global_position)

func commit_impulse_to_all_characters(origin: Vector3, power: float = 1, radius: float = -1):
	for c in list:
		if radius < 0 or origin.distance_to(c.global_position) < radius:
			c.commit_impulse(origin.direction_to(c.global_position), power)

func commit_impulse_to_all_enemies(origin: Vector3, power: float, radius: float = -1):
	for c in list:
		if not is_player(c) and not c.is_friendly:
			if radius < 0 or origin.distance_to(c.global_position) < radius:
				c.commit_impulse(origin.direction_to(c.global_position), power)

#endregion

#region: NPC update
func _update_npc(delta):
	var new_alive_enemies_count = 0
	
	#region: npc ai state update
	if npc_driver != null and ai_enabled:
		for character in list:
			if not is_player(character):
				npc_driver.update(character, delta)
	#endregion
	
	#region: updating npc stats
	for character in list:
		if not is_player(character):
			if not character.is_dead and not character.is_friendly:
				new_alive_enemies_count += 1
	
	if alive_enemies_count != new_alive_enemies_count:
		if alive_enemies_count == 0:
			on_enemies_alive.emit()
		if new_alive_enemies_count == 0:
			on_enemies_dead.emit()
		if alive_enemies_count != 0 and new_alive_enemies_count != 0:
			if new_alive_enemies_count > alive_enemies_count:
				on_enemy_alive.emit()
			else:
				on_enemy_dead.emit()
		
		alive_enemies_count = new_alive_enemies_count
	#endregion

#endregion

func should_hit(shooter: Node3D, target: Node3D) -> bool:
	if shooter is GCharacterController and target is GCharacterController:
		if target.is_dead:
			return false
		if characters.is_player(shooter) and characters.is_enemy(target) and not is_invulnerable(target):
			return true
		elif characters.is_enemy(shooter) and characters.is_player(target) and not is_invulnerable(player):
			return true
		if is_enemy_friendly_fire_enabled and characters.is_enemy(shooter) and characters.is_enemy(target) and not is_invulnerable(target):
			return true
			
	return false

func is_invulnerable(chr: GCharacterController):
	if is_player(chr):
		return chr.is_invulnerable or force_player_invulnerable
	else:
		return chr.is_invulnerable

func is_immortal(chr: GCharacterController):
	if is_player(chr):
		return chr.is_immortal or force_player_immortal
	else:
		return chr.is_immortal

