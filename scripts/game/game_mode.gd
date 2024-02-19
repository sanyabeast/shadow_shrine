extends Node3D

class_name S2GameMode

@export var seed_key: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	prepare()
	print("game mode %s: prepared" % name)
	game.set_mode(self)
	pass # Replace with function body.

func _exit_tree():
	game.unset_mode(self)

func prepare():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func start_game():
	print("game mode: staring...")

func finish_game():
	print("game mode: finishing...")
	pass
