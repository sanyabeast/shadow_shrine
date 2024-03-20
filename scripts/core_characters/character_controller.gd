# Author: @sanyabeast
# Date: Feb. 2024

extends CharacterBody3D

class_name GCharacterController
const TAG: String = "CharacterController"

signal on_hurt(health_loss: float)

class GAbility:
	signal on_changed(name: String, old_value: float, new_value: float, increased: bool)

	var name: String = ""
	var value: float = 0
	var target_value: float = 1
	var max_value: float = -1
	var transition_speed: float = 0

	func _init(_name: String, _value: float, _max_value = null, _transition_speed = null):
		name = _name

		if _max_value != null:
			max_value = _max_value

		if _transition_speed != null:
			transition_speed = _transition_speed

		set_value(_value)

	func update(delta: float):
		if transition_speed <= 0:
			value = target_value
		else:
			value = move_toward(value, target_value, transition_speed * delta)

	func alter_value(delta: float):
		set_value(target_value + delta)

	func set_value(new_value: float):
		var old_value: float = target_value

		if max_value >= 0:
			print("clamping abil value to %s %s" % [0, max_value])
			new_value = clampf(new_value, 0, max_value)

		target_value = new_value

		if new_value != old_value:
			dev.logd(TAG, "Ability %s target value set to %s" % [name, target_value])
			on_changed.emit(name, old_value, new_value, new_value > old_value)

		update(0)


var walk_power: float = 0
var walk_direction: Vector3 = Vector3.FORWARD
var look_direction: Vector3 = Vector3.FORWARD
var cooldowns: GCooldowns = GCooldowns.new(true)

var body_controller: GCharacterBodyController
var weapon: GWeaponController
var nav_agent: NavigationAgent3D = NavigationAgent3D.new()

var is_dead: bool = false

# abilities
var health: GAbility
var max_health: GAbility
var speed: GAbility
var damage: GAbility
var protection: GAbility

var impulse_direction: Vector3
var impulse_power: float = 0

var _last_damage_point: Vector3 = Vector3.ZERO

@export var config: RCharacterConfig

@onready var body: Node3D = $Body
@onready var aim_rig: Node3D = $Aim
@onready var collider: CollisionShape3D = $CollisionShape3D

@export_subgroup("Player Mode")
@export var use_as_player: bool = false

@export_subgroup("NPC Mode")
@export var ai_enabled: bool = true
@export var is_friendly: bool = false

@export_subgroup("Misc")
@export var hide_on_death: Array[Node3D] = []

signal on_fire(weapon: GWeaponController, direction: Vector3)


func _ready():
	_traverse(self)

	add_child(nav_agent)

	if body_controller != null:
		body_controller.initialize(self)

	print("maxhealth", config.max_health)
	# Abilities
	health = GAbility.new("health", config.health, config.max_health)
	max_health = GAbility.new("max_health", config.max_health)
	speed = GAbility.new("speed", config.speed)
	protection = GAbility.new("protection", config.protection)
	damage = GAbility.new("damage", config.damage)

	health.on_changed.connect(_handle_ability_change)
	max_health.on_changed.connect(_handle_ability_change)
	speed.on_changed.connect(_handle_ability_change)
	protection.on_changed.connect(_handle_ability_change)
	damage.on_changed.connect(_handle_ability_change)
	
	if use_as_player and characters.player == null:
		characters.set_player(self)


func _enter_tree():
	characters.link(self)

func _exit_tree():
	characters.unlink(self)

func _traverse(node):
	if node is GWeaponController:
		weapon = node

	if node is GCharacterBodyController:
		body_controller = node

	# Recursively call this function on all children
	for child in node.get_children():
		_traverse(child)

func _physics_process(delta):
	if not game.paused:
		var _walk_power = lerpf(walk_power, 0, clampf(pow(impulse_power, 2), 0, 1))

		velocity.x = walk_direction.x * _walk_power * speed.value * game.speed
		velocity.z = walk_direction.z * _walk_power * speed.value * game.speed

		velocity += impulse_direction * (pow(impulse_power, 0.5)) * game.speed

		#move_and_collide(global_transform.basis.z)
		velocity.y = 0
		global_position.y = 0

		move_and_slide()

		impulse_power = move_toward(impulse_power, 0, 2 * delta)

		#if not is_on_floor():
			#velocity.y += -9.8 * delta

		if not is_dead:
			if is_on_wall() and get_slide_collision_count() > 0:
				# wall impulse
				var coll: KinematicCollision3D = get_slide_collision(0)
				var collider = coll.get_collider() if coll != null else null

				if collider != null:
					if not characters.is_player(self) and collider is GridMap:
						commit_impulse(coll.get_normal(), 2)

					if collider is GCharacterController and characters.is_player(collider):
						commit_impulse(
							coll.get_normal(),
							2 * clampf(pow(collider.get_mass() / get_mass(), 2), 0, 1)
						)
						
func set_walk_power(value: float):
	walk_power = value

func set_walk_direction(value: Vector2):
	walk_direction = Vector3(value.x, 0, value.y)

func set_look_direction(value: Vector2):
	if value.length() > 0.05:
		look_direction = Vector3(value.x, 0, value.y)

func fire():
	if weapon:
		weapon.fire(look_direction)
		on_fire.emit(weapon, look_direction)

func _process(delta):
	if not game.paused:
		_update_abilities(delta)

		# Always rotate the aim node toward the aim direction
		if look_direction.length_squared() > 0:
			aim_rig.look_at(aim_rig.global_position + look_direction, Vector3.UP)

		if weapon:
			weapon.keeper = self

		dev.set_label(
			self,
			{
				"health": "Health: %s" % health.value,
				"max_health": "Max health: %s" % max_health.value,
				"speed": "Speed: %s" % speed.value
			}
		)
	
func commit_damage(value: float, point: Vector3 = Vector3.ZERO):
	_last_damage_point = to_local(point)
	health.alter_value(-value)

func commit_heal(value: float):
	health.alter_value(value)

func commit_impulse(direction: Vector3, power: float):
	impulse_direction = (impulse_direction + direction).normalized()
	impulse_direction.y = 0
	impulse_power = max(impulse_power, power)
	pass

func _handle_ability_change(name: String, old_value: float, new_value: float, increased: bool):
	dev.logd(TAG, "ability %s changed %s -> %s" % [name, old_value, new_value])

	match name:
		"health":
			if not increased:
				if config.hurt_fx != null:
					world.spawn_fx(config.hurt_fx, to_global(_last_damage_point))
				on_hurt.emit(old_value - new_value)

			if new_value == 0:
				die()

func get_mass() -> float:
	if characters.is_player(self):
		return config.mass * characters.player_mass_scale
	else:
		return config.mass

func get_scalar_velocity():
	return tools.to_v2(velocity).length()

func die():
	call_deferred("_die")
func _die():
	dev.logd(TAG, "character dies %s" % name)
	is_dead = true
	
	collision_layer = 0
	velocity.y = 0

	set_walk_power(0)

	for node in hide_on_death:
		node.visible = false
		
	collider.disabled = true	

	if config.death_fx != null:
		world.spawn_fx(config.death_fx, global_position)

func _update_abilities(delta):
	health.update(delta)
	speed.update(delta)
	protection.update(delta)
	damage.update(delta)

func is_player():
	return characters.is_player(self)
