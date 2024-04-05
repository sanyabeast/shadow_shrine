# Author: @sanyabeast
# Date: Apr. 2024

@icon("res://assets/_dev/_icons/char_35.png")
extends CharacterBody3D
class_name GCharacterController
var TAG: String = "CharacterController"

@export_subgroup("# Character Contrller")
@export var id: String = ""

@export_subgroup("# Character Contrller ~ Main")
## azimuthal look angle in degrees (0 - 360)
@export var look_angle: float = 0
@export var look_angle_alt: float = 0
@export var move_power: float = 0
@export var move_angle: float = 0
@export var move_angle_alt: float = 0

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

var cooldowns: GCooldowns = GCooldowns.new(true)

var abilities: Dictionary = {}

func _ready():
	## Called when the node is added to the scene.
	assert(id.length() > 0, "character `id` must be non-empty string, found `%s` at `%s`" % [id, name])
	_init_character()
	_init_abilities()
	
	for k in abilities.keys():
		abilities[k].on_changed.connect(_handle_ability_change)
	
	if use_as_player and characters.player == null:
		characters.set_player(self)

func _init_abilities():
	## Initializes character abilities.
	pass
	
func _init_character():
	## Initializes character properties.
	pass

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

func _handle_ability_change(name: String, old_value: float, new_value: float, increased: bool):
	## Handles changes in character abilities.
	pass
	
func _process(delta):
	## Processes non-physics related logic.
	if visible and active and not game.paused:
		_update_abilities(delta)
		_update_state(delta)
	
func _update_state(delta):
	## Updates the character's state.
	pass
	
func _physics_process(delta):
	## Processes physics-related logic.
	if visible and active and not game.paused:
		_update_physics(delta)
	
func _update_physics(delta):
	## Updates the character's physics state.
	pass
		
##region: Abilities
func add_ability(name: String, ability: GAbility):
	## Adds an ability to the character.
	abilities[name] = ability

func get_ability(name: String) -> GAbility:
	## Retrieves an ability by name.
	return abilities[name]

func get_ability_value(name: String) -> float:
	## Retrieves the value of an ability.
	var abil: GAbility = get_ability(name)
	return abil.value
	
func alter_ability(name: String, delta_value: float) -> float:
	## Alters the value of an ability.
	var abil: GAbility = get_ability(name)
	abil.alter_value(delta_value)
	return abil.value

func _update_abilities(delta):
	## Updates all character abilities.
	for k in abilities.keys():
		abilities[k].update(delta)
##endregion
