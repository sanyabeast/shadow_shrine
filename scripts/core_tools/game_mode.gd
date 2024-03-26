# Author: @sanyabeast
# Date: Feb. 2024

@icon("res://assets/_dev/_icons/dotto-emoji-main-svg/Dotto Emoji351.svg")
extends Node3D
class_name GGameMode

@export var player_driver: GPlayerDriver
@export var npc_driver: GNpcDriver

#region: Lifecycle
func _ready():
	_prepare()
	game.set_mode(self)
	pass # Replace with function body.

func _prepare():
	pass

func _process(delta):
	pass
	
func _exit_tree():
	game.unset_mode(self)
#endregion

#region: Abstract
func start_game():
	print("game mode: staring...")

func finish_game():
	print("game mode: finishing...")
	pass
#endregion

func trigger(id: String):
	dev.logd("GameMode", "implement .trigger function (triggered: %s)" % id)
	pass
