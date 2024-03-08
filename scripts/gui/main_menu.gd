# Author: @sanyabeast
# Date: Feb. 2024

extends Control

class_name S2MainMenu
const TAG: String = "MainMenu"

# Called when the node enters the scene tree for the first time.
func _ready():
	gui.main_menu = self
	dev.logd(TAG, "Main menu ready")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
