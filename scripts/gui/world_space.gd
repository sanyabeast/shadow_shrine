extends Control

class_name S2WorldSpaceGUI
const TAG: String = "WorldSpaceGUI"

# Called when the node enters the scene tree for the first time.
func _ready():
	gui.world_space = self
	dev.logd(TAG, "World space GUI ready")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
