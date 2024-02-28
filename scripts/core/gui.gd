extends Node

class_name S2GUI
const TAG: String = "GUI"

enum EMode {
	InMainMenu,
	InGame
}

var _mode: EMode = EMode.InMainMenu

var world_space: S2WorldSpaceGUI
var hud: S2HUD
var pause_menu: S2PauseMenu
var main_menu: S2MainMenu

var world_space_visible: bool = false
var hud_visible: bool = false
var pause_menu_visible: bool = false
var main_menu_visible: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	tools.logd(TAG, "GUI ready, operating mode: %s" % _mode)
	set_mode(_mode)
	pass # Replace with function body.

func set_mode(new_mode: EMode):
	tools.logd(TAG, "setting operating mode to: %s" % _mode)
	_mode = new_mode
	
	match _mode:
		EMode.InMainMenu:
			world_space_visible = false
			hud_visible = false
			pause_menu_visible = false
			main_menu_visible = true
			
		EMode.InGame:
			world_space_visible = true
			hud_visible = true
			pause_menu_visible = false
			main_menu_visible = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _mode == EMode.InGame:
		if game.paused and not pause_menu_visible:
			hud_visible = false
			pause_menu_visible = true
		elif not game.paused and pause_menu_visible:
			hud_visible = true
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
			
	if main_menu != null and main_menu.visible != main_menu_visible:
		if main_menu_visible:
			main_menu.show()
		else:
			main_menu.hide()
