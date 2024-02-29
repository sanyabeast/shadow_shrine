extends CharacterBody3D

class_name S2Character
const TAG: String = "Character"

@export var config: RCharacterConfig

@onready var body: Node3D = $Body
@onready var aim_rig: Node3D = $Aim

@export_subgroup("Player Mode")
@export var use_as_player: bool = false

@export_subgroup("NPC Mode")
@export var is_friendly: bool = false


var walk_power: float = 0
var walk_direction: Vector3 = Vector3.FORWARD
var look_direction: Vector3 = Vector3.FORWARD
var cooldowns: S2CooldownManager = S2CooldownManager.new(true)
var npc_controller: S2NPCController

var skill_system: S2SkillSystem = S2SkillSystem.new()
var weapon: S2WeaponController

func _ready():
	_traverse(self)
	
	# setting up skills
	skill_system.add_skill("health", 3, 3)
	skill_system.add_skill("speed", config.speed, config.speed)
	skill_system.add_skill("damage", 1, 0)
	skill_system.add_skill("protection", 1, 0)
	
	dev.logd(TAG, "character skill system set up: %s" % skill_system)
	
	if use_as_player:
		player.set_active(self)
		
	if npc_controller == null:
		npc_controller = S2NPCController.new()
	
	npc_controller.initialize(self)
	
	characters.register(self)

func _exit_tree():
	characters.discharge(self)

func _traverse(node):
	if node is S2WeaponController:
		weapon = node
		
	if node is S2NPCController:
		npc_controller = node
		
	# Recursively call this function on all children
	for child in node.get_children():
		_traverse(child)

func _physics_process(delta):
	if not game.paused:
		velocity.x = walk_direction.x * walk_power * config.speed
		velocity.z = walk_direction.z * walk_power * config.speed
		velocity.y = 0
		
		move_and_slide()
		
		global_position.y = 0

	
func rotate_body(delta):
	 # Rotate the body toward the move direction if not aiming
	if cooldowns.ready("body_to_look", true) and walk_direction.length_squared() > 0:
		body.look_at(body.global_position + walk_direction, Vector3.UP)
	else:
		body.look_at(body.global_position + look_direction, Vector3.UP)
		
	# Always rotate the aim node toward the aim direction
	if look_direction.length_squared() > 0:
		aim_rig.look_at(aim_rig.global_position + look_direction, Vector3.UP)

func set_walk_power(value: float):
	walk_power = round(value)
	
func set_walk_direction(value: Vector2):
	value = tools.restrict_to_8_axis(value)
	walk_direction = Vector3(value.x, 0, value.y)
	
func set_look_direction(value: Vector2):
	if value.length() > 0.1:
		print(value.length())
		cooldowns.start("body_to_look", 2)
		value = tools.restrict_to_8_axis(value)
		look_direction = Vector3(value.x, 0, value.y)

func fire():
	if weapon:
		weapon.fire(look_direction)

func _process(delta):
	#print("move direction: %s" % walk_direction)
	#print("aim direction: %s" % look_direction)
	
	rotate_body(delta)
	
	if weapon:
		weapon.keeper = self
	
	dev.set_label(self, {
		"health": "Health: %s" % skill_system.skills["health"].value,
		"speed": "Speed: %s" % skill_system.skills["speed"].value
	})
	pass
	#aim_rig.rotation_degrees.y = _target_aim_rotation
