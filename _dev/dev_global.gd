extends Node

class_name S2DevGlobal

const TAG: String = "DevScript: "

var screen_printer: S2DevScreenPrinter
var debug_labels: S2DebugLabels
var maze_painter: S2MazeDebugPainter

var _queued_screen_printer_messages = {}

# CONSOLE
func logd(tag: String, data):
	print("[ %s ]: %s" % [tag, data])
	
func logr(tag: String, data):
	print("[ %s ]: [ ERROR! ] %s" % [tag, data])

# MAZE
func set_maze_painter(node: S2MazeDebugPainter):
	maze_painter = node

# SCREEN PRINT
func print_screen(topic: String, message: String):
	if screen_printer != null:
		screen_printer.print(topic, message)
	else:
		_queued_screen_printer_messages[topic] = message


func set_screen_printer(node: S2DevScreenPrinter):
	screen_printer = node
	for key in _queued_screen_printer_messages.keys():
		print_screen(key, _queued_screen_printer_messages[key])
	_queued_screen_printer_messages = {}

# WORLD LABELS
func set_label(target: Node3D, lines: Dictionary):
	if debug_labels != null:
		debug_labels.set_label(target, lines)
	
func remove_label(target: Node3D):
	debug_labels.remove_label(target)

func set_debug_labels(node: S2DebugLabels):
	debug_labels = node
