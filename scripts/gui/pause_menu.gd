extends Control

class_name S2PauseMenu
const TAG: String = "PauseMenu"

# Called when the node enters the scene tree for the first time.
func _ready():
	gui.pause_menu = self
	dev.logd(TAG, "Pause menu ready")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
