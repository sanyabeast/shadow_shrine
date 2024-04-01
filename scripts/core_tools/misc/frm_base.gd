# Author: @sanyabeast
# Date: Mar. 2024

extends Node
class_name GFreeroamMode
const TAG:= "FreeroamMode"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _teleport():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_start():
	pass

func handle_player_dead():
	game.finish(false)
	pass

func handle_enemies_appear():
	pass

func handle_enemies_disappear():
	pass
