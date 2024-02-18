extends Node

class_name PlayerManager

const TAG: String = "PlayerManager: "

var current: S2Character

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

func is_player(character: S2Character) -> bool:
	return character == current

func teleport(position: Vector3):
	if current != null:
		current.global_position = position
	else:
		print(TAG + "no players to teleport")
