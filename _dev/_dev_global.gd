# Author: @sanyabeast
# Date: Jan. 2024

extends Node
class_name GDevManager
const TAG: String = "DevManager"

var screen_printer: GDevScreenPrinter
var debug_labels: GDevLabels
var maze_painter: GDevMazePainter
var show_debug_graphics: bool = false

var _queued_screen_printer_messages = {}

func _ready():
	show_debug_graphics = tools.IS_DEBUG
	show_debug_graphics = false

# CONSOLE
func logd(tag: String, data):
	print("[ %s ]: %s" % [tag, data])
	
func logr(tag: String, data):
	print("[ %s ]: [ ERROR! ] %s" % [tag, data])

# MAZE
func set_maze_painter(node: GDevMazePainter):
	maze_painter = node

# SCREEN PRINT
func print_screen(topic: String, message: String):
	if screen_printer != null:
		screen_printer.print(topic, message)
	else:
		_queued_screen_printer_messages[topic] = message

func set_screen_printer(node: GDevScreenPrinter):
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

func set_debug_labels(node: GDevLabels):
	debug_labels = node

func _process(delta):
	if tools.IS_DEBUG:
		if Input.is_action_just_pressed("_dev_toggle_gizmo"):
			show_debug_graphics = not show_debug_graphics
	else:
		show_debug_graphics = false
			
	if debug_labels != null:
		debug_labels.visible = show_debug_graphics
		
	if screen_printer != null:
		screen_printer.visible = show_debug_graphics	
		
	if maze_painter != null:
		maze_painter.visible = show_debug_graphics	
