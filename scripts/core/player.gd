# Author: @sanyabeast
# Date: Feb. 2024

extends Node

class_name PlayerManager

const TAG: String = "PlayerManager: "

var current: S2Character
var mass_scale: float = 4

func set_active(character: S2Character):
	print("player manager: active character: %s" % character)
	current = character

# Called when the node enters the scene tree for the first time.
func _ready():
	print("player manager: ready...")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _physics_process(delta):
	if not game.paused:
		if current != null:
			# Get the input direction and handle the movement/deceleration.
			# As good practice, you should replace UI actions with custom gameplay actions.
			var walk_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
			var look_input = Input.get_vector("shoot_left", "shoot_right", "shoot_up", "shoot_down")
			
			current.set_walk_power(walk_input.length())
			current.set_walk_direction(walk_input.normalized())
			current.set_look_direction(look_input.normalized())
			
			if look_input.length() > 0.1:
				current.fire()

func is_player(character: S2Character) -> bool:
	return character == current

func teleport(position: Vector3):
	if current != null:
		current.global_position = position
	else:
		print(TAG + "no players to teleport")
