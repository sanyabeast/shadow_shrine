# Author: @sanyabeast
# Date: Feb. 2024

@icon("res://assets/_dev/_icons/char_35b.png")
extends GCharacterController
class_name GTopDownCharacterController

signal on_hurt(health_loss: float, point: Vector3, direction: Vector3)
signal on_fire(weapon: GWeaponController, direction: Vector3)

@export_subgroup("# Top-down Character Controller")
@export var config: RCharacterConfig
@onready var aim_rig: Node3D = $Aim
@onready var collider: CollisionShape3D = $CollisionShape3D

@export_subgroup("# Top-down Character Controller ~ Misc")
@export var hide_on_death: Array[Node3D] = []

@export_subgroup("# Top-down Character Controller ~ Referencies")
@export var body_controller: GCharacterBodyController
@export var weapon: GWeaponController

var walk_power: float = 0
var walk_direction: Vector3 = Vector3.FORWARD
var look_direction: Vector3 = Vector3.FORWARD

var nav_agent: NavigationAgent3D = NavigationAgent3D.new()

var _last_damage_point: Vector3 = Vector3.ZERO
var _last_damage_direction: Vector3 = Vector3.ZERO

var has_weapon: bool:
	get:
		return weapon != null

func _init_character():
	tools.traverse(self, _init_child_node)
	
	add_child(nav_agent)

	if body_controller != null:
		body_controller.initialize(self)
		
	if weapon != null:
		weapon.keeper = self	

func _init_child_node(node):
	if weapon == null and node is GWeaponController:
		weapon = node

	if body_controller == null and node is GCharacterBodyController:
		body_controller = node

func _init_abilities():
	# Abilities
	add_ability("health", GAbility.new("health", config.health, config.max_health))
	add_ability("max_health", GAbility.new("max_health", config.max_health))
	add_ability("speed", GAbility.new("speed", config.speed))
	add_ability("protection", GAbility.new("protection", config.protection))
	add_ability("damage", GAbility.new("damage", config.damage))

func _update_physics(delta):
	var _walk_power = walk_power
	_walk_power = lerpf(walk_power, 0, clampf(pow(impulse_power, 2), 0, 1))
		
	velocity.x = walk_direction.x * _walk_power * get_ability_value("speed") * game.speed
	velocity.z = walk_direction.z * _walk_power * get_ability_value("speed") * game.speed
	velocity += impulse_direction * (pow(impulse_power / config.stability, 0.5)) * game.speed

	match characters.vertical_mobility_mode:
		GCharactersManager.ECharacterVerticalMobilityMode.GRAVITY:
			if not is_on_floor():
				velocity.y += (world.gravity * delta) * config.gravity_scale
			else:
				velocity.y = 0
		GCharactersManager.ECharacterVerticalMobilityMode.LOCK_0:
			velocity.y = 0
			global_position.y = 0

	if not is_dead:
		if is_on_wall() and get_slide_collision_count() > 0:
			# wall impulse
			var coll: KinematicCollision3D = get_slide_collision(0)
			var collider = coll.get_collider() if coll != null else null

			if collider != null:
				if not characters.is_player(self) and collider is GridMap:
					world.commit_impulse(self, coll.get_normal(), 1)
					
	move_and_slide()
		
func set_walk_power(value: float):
	if not is_dead:
		walk_power = value

func set_walk_direction(value: Vector2):
	if not is_dead:
		walk_direction = Vector3(value.x, 0, value.y)

func set_look_direction(value: Vector2):
	if not is_dead and value.length() > 0.05:
		look_direction = Vector3(value.x, 0, value.y)
		
func fire():
	if not is_dead and has_weapon:
		weapon.fire(look_direction)
		on_fire.emit(weapon, look_direction)

func _update_state(delta):
	# Always rotate the aim node toward the aim direction
	if look_direction.length_squared() > 0:
		aim_rig.look_at(aim_rig.global_position + look_direction, Vector3.UP)

	if tools.IS_DEBUG:
		nav_agent.debug_enabled = dev.show_debug_graphics
		if nav_agent.debug_enabled:
			nav_agent.debug_path_custom_color = Color.from_hsv(
				fmod(float(get_instance_id()) / 90, 1.),
				1.,
				0.5,
				1.0
			)
			nav_agent.debug_use_custom = true

func commit_damage(value: float, point: Vector3 = Vector3.ZERO, direction: Vector3 = Vector3.ZERO):
	if not characters.is_invulnerable(self):
		_last_damage_point = to_local(point)
		_last_damage_direction = direction
		alter_ability("health", -value)

func commit_heal(value: float):
	alter_ability("health", value)

func _handle_ability_change(name: String, old_value: float, new_value: float, increased: bool):
	#dev.logd(TAG, "ability %s changed %s -> %s" % [name, old_value, new_value])
	match name:
		"health":
			if not increased:
				on_hurt.emit(old_value - new_value, _last_damage_point, _last_damage_direction)
				
				if config.hurt_fx != null:
					world.spawn_fx(config.hurt_fx, to_global(_last_damage_point))
				
			if new_value == 0 and not characters.is_immortal(self):
				die()

func _on_die():
	collision_layer = 0
	velocity.y = 0

	set_walk_power(0)

	for node in hide_on_death:
		node.visible = false
		
	if config.death_fx != null:
		world.spawn_fx(config.death_fx, global_position)
	
	if body_controller != null:
		body_controller.die()
	else:
		queue_free()


