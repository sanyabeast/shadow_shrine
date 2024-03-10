# Author: @sanyabeast
# Date: Feb. 2024

extends Node

class_name S2GameManager
const TAG: String = "GameManager"

var mode: S2GameMode
var time: float = 0
var speed: float = 1
var paused: bool = true
var ai_enabled: bool = false

var timer_gate: S2TimerGateManager = S2TimerGateManager.new(true)

# Called when the node enters the scene tree for the first time.
func _ready():
	print("game manager: ready...")
	pass # Replace with function body.

func set_mode(_mode: S2GameMode):
	if mode != null:
		unset_mode(mode)
		
	print("game: setting game mode to %s" % _mode)
	set_seed(_mode.seed_key)
	mode = _mode
	
func set_seed(seed_key: int):
	seed(seed_key)
	
func unset_mode(_mode: S2GameMode):
	if mode == _mode:
		mode.finish_game()
		mode = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not paused: 
		time += delta * speed
		
	dev.print_screen("game_timme", "game time: %s" % [time])	
	pass

func get_time() -> float:
	return time

func resume():
	paused = false
	
func pause():
	paused = true

func enable_ai():
	dev.logd(TAG, "ai enabled")
	ai_enabled = true

func disable_ai():
	dev.logd(TAG, "ai disabled")
	ai_enabled = false