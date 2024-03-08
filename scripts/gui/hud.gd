# Author: @sanyabeast
# Date: Feb. 2024

extends Control

class_name S2HUD
const TAG: String = "HUD"

# Called when the node enters the scene tree for the first time.
func _ready():
	gui.hud = self
	dev.logd(TAG, "HUD ready")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
