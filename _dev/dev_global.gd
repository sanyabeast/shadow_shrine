extends Node

class_name S2DevGlobal

const TAG: String = "DevScript: "

var screen_printer: S2DevScreenPrinter
var maze_painter: S2MazeDebugPainter

var _queued_screen_printer_messages = {}

func logd(tag: String, data):
	print("%s: %s" % [tag, data])
	
func logr(tag: String, data):
	print("%s: [ERROR!] %s" % [tag, data])

func print_screen(topic: String, message: String):
	if screen_printer != null:
		screen_printer.print(topic, message)
	else:
		_queued_screen_printer_messages[topic] = message

func set_maze_painter(node: S2MazeDebugPainter):
	maze_painter = node

func set_screen_printer(node: S2DevScreenPrinter):
	screen_printer = node
	for key in _queued_screen_printer_messages.keys():
		print_screen(key, _queued_screen_printer_messages[key])
	_queued_screen_printer_messages = {}
