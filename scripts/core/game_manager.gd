# Author: @sanyabeast
# Date: Feb. 2024

extends Node
class_name GGameManager
var TAG: String = "GameManager"

var mode: GGameMode
var time: float = 0
var speed: float = 1
var paused: bool = true
var tasks: GTasker = GTasker.new(true)
var timer_gate: GTimeGateHelper = GTimeGateHelper.new(true)
var seed: int = 0

var is_over: bool = false
var is_won: bool = false

var thesaurus: GThesaurus
var difficulty: float = 1

var random:= GRandHelper.new()

signal on_seed_changed(seed: int)

# Called when the node enters the scene tree for the first time.
func _ready():
	var saved_seed: int = app.get_setting("game_seed", randi())
	set_seed(saved_seed)
	pass # Replace with function body.

func set_seed(_seed: int, force: bool = false):
	if seed != _seed or force:
		seed = _seed
		random.set_seed(_seed)
		dev.logd(TAG, "seed set to %s" % seed)
		app.set_setting("game_seed", seed)
		on_seed_changed.emit(seed)
	
func set_mode(_mode: GGameMode):
	if mode != null:
		unset_mode(mode)
		
	mode = _mode
	
	if mode.player_driver != null:
		characters.set_player_driver(mode.player_driver)
	
	if mode.npc_driver != null:
		characters.set_npc_driver(mode.npc_driver)
		
func unset_mode(_mode: GGameMode):
	if mode == _mode:
		mode.finish_game()
		mode = null
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not paused: 
		tasks.update()
		time += delta * speed
	
	widgets.tokens["game_time"] = game.time
	
	if tools.IS_DEBUG:
		dev.print_screen("game_stats", "game (mode / seed / time): %s / %s / %2.2f" % [mode.name if mode != null else "null", seed, time])

func get_time() -> float:
	return time

func resume():
	paused = false
	
func pause():
	paused = true

func finish(_is_won: bool):
	dev.logd(TAG, "game finished, player: %s" % ("won" if _is_won else "lose"))
	is_over = true
	is_won = _is_won

func start():
	dev.logd(TAG, "starting new game, resetting win status")
	is_over = false
	is_won = false
	
	if mode != null:
		mode.start_game()

func quit():
	if mode != null:
		mode.quit()
	else:
		app.load_main_menu_level()

func set_thesaurus(_thesaurus: GThesaurus):
	dev.logd(TAG, "changing thesaurus to `%s`" % _thesaurus.id)
	thesaurus = _thesaurus
