# Author: @sanyabeast
# Date: Feb. 2024

@icon("res://assets/_dev/_icons/dotto-emoji-main-svg/Dotto Emoji187.svg")
extends Node3D

class_name GCharacterBodyController
const TAG: String = "CharacterBodyController"

@export_subgroup("# CharacterBodyController")
@export var surface_material_helper: GSurfaceMaterialHelper
@export var footsteps_sfx: AudioStreamPlayer3D
@export var footsteps_max_volume: float = 0.5

var character: GCharacterController
var anim_tree: AnimationTree
var is_initialized: bool = false

var cooldowns: GCooldowns = GCooldowns.new(true)
var tasks: GTasker = GTasker.new(true)
var _prev_look_direction: Vector3 = Vector3.UP
var _scalar_velocity_smoothed: float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	if footsteps_sfx != null:
		footsteps_sfx.seek(randf() * footsteps_sfx.stream.get_length())

func initialize(_character: GCharacterController):
	character = _character
	character.on_fire.connect(_handle_character_fires)
	character.on_hurt.connect(_handle_character_hurt)
	_traverse(self)
	
	if surface_material_helper != null:
		surface_material_helper.enter_state("default")
	
	is_initialized = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_initialized:
		tasks.update()
		_rotate_body(delta)
		if anim_tree != null:
			_update_anim_tree(delta)
		if surface_material_helper != null:
			_update_surface(delta)	
			
		_scalar_velocity_smoothed = lerpf(_scalar_velocity_smoothed, character.get_scalar_velocity(), 0.2)
		
		if footsteps_sfx != null:
			_update_footsteps_sfx()
	pass

func _update_footsteps_sfx():
	footsteps_sfx.volume_db = linear_to_db(
		clampf((character.velocity.length() / character.speed.value) * footsteps_max_volume, 0., 1.)
	)

func _traverse(node):
	if node is AnimationTree:
		anim_tree = node
		
	# Recursively call this function on all children
	for child in node.get_children():
		_traverse(child)

func _rotate_body(delta):
	if not game.paused:
		var walk_direction = character.walk_direction
		var look_direction = character.look_direction
		var body_direction = look_direction
		
		 # Rotate the body toward the move direction if not aiming
		if cooldowns.ready("body_to_look", true):
			if walk_direction.length_squared() > 0.1:
				body_direction = walk_direction
				#look_at(global_position + walk_direction, Vector3.UP)
			else:
				return
			
		global_rotation_degrees.y = tools.move_toward_deg(
			global_rotation_degrees.y,
			tools.rotation_degrees_y_from_direction(-body_direction),
			720 * delta
		)
		
func _update_anim_tree(delta):
	var walk_direction = character.velocity.normalized()
	#anim_tree["parameters/Move/blend_position"] = clamp(walk_direction.length(),0,1)
	anim_tree["parameters/Move/blend_position"] = _scalar_velocity_smoothed
	if game.paused:
		anim_tree["parameters/Move/blend_position"] = 0
	anim_tree["parameters/conditions/is_dead"] = character.is_dead
	
func _handle_character_fires(weapon: GWeaponController, direction: Vector3):
	cooldowns.start("body_to_look", 0.25)

func _handle_character_hurt(health_loss: float, point:= Vector3.ZERO, direction:= Vector3.ZERO):
	#dev.logd(TAG, "_handle_character_hurt %s" % health_loss)
	if surface_material_helper != null:
		surface_material_helper.enter_state("hurt", 0)

func _update_surface(delta):
	if surface_material_helper.current_state_id == "hurt":
		surface_material_helper.enter_state("default", 0.25)

func die():
	game.tasks.schedule(game, str(character.get_instance_id()) + "-dies", 5, character.queue_free)
