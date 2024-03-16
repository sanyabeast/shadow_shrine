# Author: @sanyabeast
# Date: Feb. 2024

extends Node
class_name PlayerManager
const TAG: String = "PlayerManager: "

var current: S2Character
var mass_scale: float = 10

func set_active(character: S2Character):
	print("player manager: active character: %s" % character)
	current = character

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if current != null:
		#widgets.set_token("player_health", current.health.value)
		widgets.set_token("player_health", fmod(game.time, 3))
		widgets.set_token("player_max_health", current.max_health.value)
	
func _physics_process(delta):
	if not game.paused and not game.is_over:
		if current != null:
			# Get the input direction and handle the movement/deceleration.
			# As good practice, you should replace UI actions with custom gameplay actions.
			var walk_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
			var look_input = Input.get_vector("shoot_left", "shoot_right", "shoot_up", "shoot_down")
			
			walk_input = tools.restrict_to_8_axis(walk_input)
			look_input = tools.restrict_to_8_axis(look_input)
			
			current.set_walk_power(round(walk_input.length()))
			current.set_walk_direction(walk_input.normalized())
			current.set_look_direction(look_input.normalized())
			
			if look_input.length() > 0.1:
				current.fire()
	else:
		if current != null:
			current.set_walk_power(0)
		
func is_player(character: S2Character) -> bool:
	return character == current

func teleport(position: Vector3):
	if current != null:
		current.global_position = position
	else:
		tools.logd(TAG, "no players to teleport")
