# Author: @sanyabeast
# Date: Feb. 2024

extends Control

class_name GDefaultGameWidget
const TAG: String = "DefaultGameWidget"

@onready var world_space: GWidgetWorldSpace = $WorldSpace
@onready var hud: GWidgetHUD = $HUD
@onready var pause_menu: GPauseMenuWidget = $PauseMenu
@onready var screen_fx: GScreenFX = $ScreenFX
@onready var game_over_screen: GMenuController = $GameOver
@onready var highlights: GHighlightsWidget = $HighlightsWidget

var world_space_visible: bool = true
var hud_visible: bool = false
var pause_menu_visible: bool = false
var game_over_screen_visible: bool = false
var highlights_visible: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	tools.logd(TAG, "In-Game GUI ready, operating mode")
	widgets.set_controller(self)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game.paused:
		hud_visible = false
		world_space_visible = true
		pause_menu_visible = true
		game_over_screen_visible = false
		highlights_visible = false
	elif not game.paused:
		hud_visible = true
		world_space_visible = true
		pause_menu_visible = false
		game_over_screen_visible = false
		highlights_visible = highlights.messages.size() > 0 or highlights.is_showing
	
	if game.is_over:
		if game.is_won:
			pass
		else:
			hud_visible = false
			world_space_visible = false
			pause_menu_visible = false
			game_over_screen_visible= true
			highlights_visible = false
		
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

	if game_over_screen != null and game_over_screen.visible != game_over_screen_visible:
		if game_over_screen_visible:
			game_over_screen.show()
		else:
			game_over_screen.hide()

	if highlights != null and highlights.visible != highlights_visible:
		if highlights_visible:
			highlights.show()
		else:
			highlights.hide()
