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
	_traverse(self)
	is_initialized = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_initialized:
		
		if _prev_look_direction != character.look_direction and _prev_look_direction != Vector3.UP:
			cooldowns.start("body_to_look", 2)
		
		_rotate_body(delta)
		
		if anim_tree != null:
			_update_anim_tree(delta)
			
		_prev_look_direction = character.look_direction
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
	 # Rotate the body toward the move direction if not aiming
	if cooldowns.ready("body_to_look", true) and walk_direction.length_squared() > 0:
		look_at(global_position + walk_direction, Vector3.UP)
	else:
		look_at(global_position + look_direction, Vector3.UP)
		
func _update_anim_tree(delta):
	var walk_direction = character.velocity.normalized()
	anim_tree["parameters/Move/blend_position"] = clamp( walk_direction.length(),0,1)
	
