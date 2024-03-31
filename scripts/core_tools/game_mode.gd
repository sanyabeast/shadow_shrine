# Author: @sanyabeast
# Date: Feb. 2024

@icon("res://assets/_dev/_icons/dotto-emoji-main-svg/Dotto Emoji351.svg")
extends Node3D
class_name GGameMode

@export_subgroup("# Game Mode")
@export var player_driver: GPlayerDriver
@export var npc_driver: GNpcDriver
@export var thesaurus: GThesaurus

var cooldowns:= GCooldowns.new(true)

#region: Lifecycle
func _ready():
	_prepare()
	game.set_mode(self)
	if thesaurus != null:
		game.set_thesaurus(thesaurus)
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

func trigger(id: String, source: Node3D):
	_process_trigger(id, source)

func _process_trigger(id: String, source: Node3D):
	dev.logd("GameMode", "implement ._process_trigger function (triggered: %s)" % id)

func quit():
	app.load_main_menu_level()
	pass
