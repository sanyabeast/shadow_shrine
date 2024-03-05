extends Node3D

class_name S2CharacterBody
const TAG: String = "CharacterBody"

var character: S2Character
var anim_tree: AnimationTree
var is_initialized: bool = false

var cooldowns: S2CooldownManager = S2CooldownManager.new(true)
var _prev_look_direction: Vector3 = Vector3.UP

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func initialize(_character: S2Character):
	character = _character
	character.on_fire.connect(_handle_character_fires)
	_traverse(self)
	is_initialized = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_initialized:
		_rotate_body(delta)
		if anim_tree != null:
			_update_anim_tree(delta)
	pass

func _traverse(node):
	if node is AnimationTree:
		anim_tree = node
		
	# Recursively call this function on all children
	for child in node.get_children():
		_traverse(child)

func _rotate_body(delta):
	var walk_direction = character.walk_direction
	var look_direction = character.look_direction
	var body_direction = look_direction
	
	 # Rotate the body toward the move direction if not aiming
	if cooldowns.ready("body_to_look", true):
		if walk_direction.length_squared() > 0.1:
			body_direction = walk_direction
			look_at(global_position + walk_direction, Vector3.UP)
		else:
			return
		
	look_at(global_position + body_direction, Vector3.UP)	
		
func _update_anim_tree(delta):
	var walk_direction = character.velocity.normalized()
	anim_tree["parameters/Move/blend_position"] = clamp( walk_direction.length(),0,1)
	anim_tree["parameters/conditions/is_dead"] = character.is_dead
	
func _handle_character_fires(weapon: S2WeaponController, direction: Vector3):
	cooldowns.start("body_to_look", 0.25)
