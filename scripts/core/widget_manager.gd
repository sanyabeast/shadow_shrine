extends Node

class_name GWidgetManager
var TAG: String = "WidgetManager"

var controller
var tokens: Dictionary

func _ready():
	set_token("app_version", ProjectSettings.get_setting("application/config/version", "0.0.0.0"))
	set_token("app_build_type", "dev" if tools.IS_DEBUG else "release")

func set_controller(_controller):
	controller = _controller

func set_token(name: String, value):
	tokens[name] = value

func get_token(name: String, ifnotfound = null):
	if tokens.has(name):
		return tokens.get(name)
	else:
		return ifnotfound
