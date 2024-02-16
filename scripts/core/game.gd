extends Node

class_name S2GameManager

var game_mode: S2GameMode

# Called when the node enters the scene tree for the first time.
func _ready():
	print("game manager: ready...")
	pass # Replace with function body.

func set_game_mode(_game_mode: S2GameMode):
	if game_mode != null:
		unset_game_mode(game_mode)
		
	print("game: setting game mode to %s" % _game_mode)
	game_mode = _game_mode

func unset_game_mode(_game_mode: S2GameMode):
	if game_mode == _game_mode:
		game_mode.finish_game()
		game_mode = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
