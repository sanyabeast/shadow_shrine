# Author: @sanyabeast
# Date: Feb. 2024

extends Control

class_name S2InGameGUI
const TAG: String = "nGameGUI"

@onready var world_space: S2WorldSpaceGUI = $WorldSpace
@onready var hud: S2HUD = $HUD
@onready var pause_menu: S2PauseMenu = $PauseMenu
@onready var screen_fx: S2ScreenFX = $ScreenFX

var world_space_visible: bool = true
var hud_visible: bool = false
var pause_menu_visible: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	tools.logd(TAG, "In-Game GUI ready, operating mode")
	gui.set_controller(self)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game.paused and not pause_menu_visible:
		hud_visible = false
		world_space_visible = true
		pause_menu_visible = true
	elif not game.paused and pause_menu_visible:
		hud_visible = true
		world_space_visible = true
		pause_menu_visible = false

	# applying visibility
	if world_space != null and world_space.visible != world_space_visible:
		if world_space_visible:
			world_space.show()
		else:
			world_space.hide()
	
	if hud != null and hud.visible != hud_visible:
		if hud_visible:
			hud.show()
		else:
			hud.hide()
			
	if pause_menu != null and pause_menu.visible != pause_menu_visible:
		if pause_menu_visible:
			pause_menu.show()
		else:
			pause_menu.hide()
