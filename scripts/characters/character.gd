# Author: @sanyabeast
# Date: Feb. 2024

extends CharacterBody3D

class_name S2Character
const TAG: String = "Character"

class S2CharacterAbility:
	var name: String = ""
	var value: float = 0
	var target_value: float = 1
	var max_value: float = -1
	var transition_speed: float = 0
	
	signal on_changed(name: String, old_value: float, new_value: float, increased: bool)
	
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

@export var config: RCharacterConfig

@onready var body: Node3D = $Body
@onready var aim_rig: Node3D = $Aim
@onready var collider: CollisionShape3D = $CollisionShape3D
@onready var aura: Area3D = $Aura

@export_subgroup("Player Mode")
@export var use_as_player: bool = false

@export_subgroup("NPC Mode")
@export var ai_enabled: bool = true
@export var is_friendly: bool = false

@export_subgroup("Misc")
@export var hide_on_death: Array[Node3D] = []

var walk_power: float = 0
var walk_direction: Vector3 = Vector3.FORWARD
var look_direction: Vector3 = Vector3.FORWARD
var cooldowns: S2CooldownManager = S2CooldownManager.new(true)
var npc_controller: S2NPCController

var body_controller: S2CharacterBody
var weapon: S2WeaponController

var is_dead: bool = false

# abilities
var health: S2CharacterAbility
var max_health: S2CharacterAbility
var speed: S2CharacterAbility
var damage: S2CharacterAbility
var protection: S2CharacterAbility

var impulse_direction: Vector3
var impulse_power: float = 0

signal on_fire(weapon: S2WeaponController, direction: Vector3)

func _ready():
	_traverse(self)
	
	if use_as_player and player_manager.current == null:
		player_manager.set_active(self)
		
	if npc_controller == null:
		npc_controller = S2NPCController.new()
	
	if body_controller != null:
		body_controller.initialize(self)
	
	print("maxhealth", config.max_health)
 	# Abilities
	health = S2CharacterAbility.new("health", config.health, config.max_health)
	max_health = S2CharacterAbility.new("max_health", config.max_health)
	speed = S2CharacterAbility.new("speed", config.speed)
	protection = S2CharacterAbility.new("protection", config.protection)
	damage = S2CharacterAbility.new("damage", config.damage)
	
	health.on_changed.connect(_handle_ability_change)
	max_health.on_changed.connect(_handle_ability_change)
	speed.on_changed.connect(_handle_ability_change)
	protection.on_changed.connect(_handle_ability_change)
	damage.on_changed.connect(_handle_ability_change)
	
	aura.body_entered.connect(_handle_aura_body_entered)
	aura.body_exited.connect(_handle_aura_body_exited)
	
	npc_controller.initialize(self)

func _traverse(node):
	if node is S2WeaponController:
		weapon = node
		
	if node is S2NPCController:
		npc_controller = node
		
	if node is S2CharacterBody:
		body_controller = node
		
	# Recursively call this function on all children
	for child in node.get_children():
		_traverse(child)

func _physics_process(delta):
	if not game.paused:
		
		velocity.x = walk_direction.x * walk_power * speed.value * game.speed
		velocity.z = walk_direction.z * walk_power * speed.value * game.speed
		
		velocity += impulse_direction * (impulse_power) * game.speed;
		velocity.y = 0
				
		move_and_slide()
		#move_and_collide(global_transform.basis.z)
		global_position.y = 0
		
		impulse_power = move_toward(impulse_power, 0, 2 * delta)
		
		# wall impulse
		if not player_manager.is_player(self) and is_on_wall() and get_slide_collision_count() > 0:
			var coll: KinematicCollision3D = get_slide_collision(0)
			if coll != null and coll.get_collider() is GridMap:
				commit_impulse(coll.get_normal(), 1)
		
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
	#print("move direction: %s" % walk_direction)
	#print("aim direction: %s" % look_direction)
	
	#rotate_body(delta)
	
	if not player_manager.is_player(self):
		npc_controller.update(delta)
	
	_update_abilities(delta)
	
	# Always rotate the aim node toward the aim direction
	if look_direction.length_squared() > 0:
		aim_rig.look_at(aim_rig.global_position + look_direction, Vector3.UP)
	
	if weapon:
		weapon.keeper = self
	
	dev.set_label(self, {
		"health": "Health: %s" % health.value,
		"max_health": "Max health: %s" % max_health.value,
		"speed": "Speed: %s" % speed.value
	})
	pass
	#aim_rig.rotation_degrees.y = _target_aim_rotation

func commit_damage(value: float):
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
					world.spawn_fx(config.hurt_fx, global_position)
					
			if new_value == 0:
				die()
			
	pass
	
func _handle_aura_body_entered(body):
	if body != self:
		print("body entered to aura of %s, body: %s" % [name, body])
		if body is S2Character:
			if not player_manager.is_player(self):
				commit_impulse(
					body.global_position.direction_to(global_position), 
					min(config.speed * 1.25,  body.get_mass() / get_mass())
				)
		
		print(body)
		pass
	
func _handle_aura_body_exited(body):
	if body != self:
		pass
	
func get_mass() -> float:
	if player_manager.is_player(self):
		return config.mass * player_manager.mass_scale
	else:
		return config.mass

func get_scalar_velocity():
	return tools.to_v2(velocity).length()
	
func die():
	dev.logd(TAG, "character dies %s" % name)
	is_dead = true
	collision_layer = 0
	set_walk_power(0)
	
	for node in hide_on_death:
		node.visible = false
	
	collider.disabled = true
	collider.process_mode = Node.PROCESS_MODE_DISABLED
	
	if config.death_fx != null:
		world.spawn_fx(config.death_fx, global_position)
	
func _update_abilities(delta):
	health.update(delta)
	speed.update(delta)
	protection.update(delta)
	damage.update(delta)
