# Author: @sanyabeast
# Date: Apr. 2024

@icon("res://assets/_dev/_icons/char_35.png")
extends CharacterBody3D
class_name GCharacterController
var TAG: String = "CharacterController"

@export_subgroup("# Character Contrller")
@export var id: String = ""

@export_subgroup("# Character Contrller ~ Player Mode")
@export var use_as_player: bool = false

@export_subgroup("# Character Contrllerr ~ NPC Mode")
@export var ai_enabled: bool = true
@export var is_friendly: bool = false

@export_subgroup("# Character Contrller ~ Misc")
@export var active: bool = true
@export var is_invulnerable: bool = false
@export var is_immortal: bool = false

var is_dead: bool = false
var impulse_direction: Vector3
var impulse_power: float = 0

var properties: Dictionary = {}
var talents: Dictionary = {}

var _property_list: Array[GProperty] = []
var _talent_list: Array[GTalent] = []

var cooldowns: GCooldowns = GCooldowns.new(true)

func _ready():
	## Called when the node is added to the scene.
	assert(id.length() > 0, "character `id` must be non-empty string, found `%s` at `%s`" % [id, name])
	_init_character()
	_init_properties()
	_init_talents()
	
	for k in properties.keys():
		properties[k].on_changed.connect(_handle_property_change)
	
	if use_as_player and characters.player == null:
		characters.set_player(self)

func _init_character():
	## Initializes character properties.
	pass
	
func _init_properties():
	## Initializes character properties.
	pass
	
func _init_talents():
	for node in  get_children():
		if node is GTalent:
			add_talent(node.id, node)

func _to_string():
	## Returns a string representation of the character.
	return "CharacterController(name: %s)" % [name]

func is_player():
	## Checks if the character is controlled by the player.
	return characters.is_player(self)

func _enter_tree():
	## Called when the node enters the scene tree.
	characters.link(self)

func _exit_tree():
	## Called when the node exits the scene tree.
	characters.unlink(self)

func get_scalar_velocity():
	## Returns the scalar velocity of the character.
	return tools.to_v2(velocity).length()

func die():
	## Marks the character as dead and triggers death-related actions.
	dev.logd(TAG, "character dies %s" % name)
	is_dead = true
	call_deferred("_on_die")
	
func _on_die():
	## Handles the character's death.
	queue_free()

func _handle_property_change(name: String, old_value: float, new_value: float, increased: bool):
	## Handles changes in character properties.
	pass
	
func _process(delta):
	## Processes non-physics related logic.
	if visible and active and not game.paused:
		_update_properties(delta)
		_update_talents(delta)
		_update_state(delta)
		
	
func _update_state(delta):
	## Updates the character's state.
	pass
	
func _physics_process(delta):
	## Processes physics-related logic.
	if visible and active and not game.paused:
		_update_talents_physics(delta)
		_update_physics(delta)
	
func _update_physics(delta):
	## Updates the character's physics state.
	pass
		
##region: Abilities
func add_property(name: String, property: GProperty):
	## Adds an property to the character.
	properties[name] = property
	_update_property_list()

func get_property(name: String) -> GProperty:
	## Retrieves an property by name.
	return properties[name]

func get_property_value(name: String) -> float:
	## Retrieves the value of an property.
	var property: GProperty = get_property(name)
	return property.value
	
func alter_property(name: String, delta_value: float) -> bool:
	## Alters the value of an property.
	var property: GProperty = get_property(name)
	return property.alter_value(delta_value)

func is_property_maxed(name: String)-> bool:
	var property: GProperty = get_property(name)
	return property.is_maxed

func _update_properties(delta):
	## Updates all character properties.
	for p in _property_list:
		p.update(delta)
		
func _update_property_list():
	var new_list: Array[GProperty] = []
	for prop in properties.values():
		new_list.append(prop)
	_property_list = new_list
##endregion

#region: Talents
func add_talent(id: String, talent: GTalent):
	## Adds an talent to the character.
	talents[id] = talent
	_update_talent_list()

func get_talent(id: String) -> GTalent:
	return talents[id]
	
func _update_talents(delta):
	for k in talents.keys():
		talents[k].update(delta)

func _update_talents_physics(delta):
	for t in _talent_list:
		t.update_physics(delta)

func _update_talent_list():
	var new_list: Array[GTalent] = []
	for talent in talents.values():
		new_list.append(talent)
	_talent_list = new_list
#endregion
