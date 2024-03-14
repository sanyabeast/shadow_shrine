extends Node

class_name S2GUI
const TAG: String = "GUI"

var controller
var tokens: Dictionary

func set_controller(_controller):
	controller = _controller

func set_token(name: String, value):
	tokens[name] = value

func get_token(name: String, ifnotfound = null):
	if tokens.has(name):
		return tokens.get(name)
	else:
		return ifnotfound
