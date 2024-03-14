extends Node

class_name S2GUI
const TAG: String = "GUI"

var controller
var tokens: Dictionary

func set_controller(_controller):
	controller = _controller
