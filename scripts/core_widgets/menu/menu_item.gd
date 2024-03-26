# Author: @sanyabeast
# Date: Feb. 2024

# This script defines a menu item control with customizable options and animations.

@icon("res://assets/_dev/_icons/dotto-emoji-main-svg/Dotto Emoji191.svg")
extends Control
class_name GMenuItem
const TAG: String = "MenuItem"

# Exported variables for customization.
@export var id: String = ""
@export var has_options: bool = false
@export var value: float = 0
@export var min_value: float = 0
@export var max_value: float = 1
@export var step: float = 1
@export var options: Array[String] = []  # Array of options for the menu item.
@export var option_index: int = 0  # Index of the selected option.
@export var anim_player: AnimationPlayer  # Animation player for menu item animations.

var _mouse_entered: bool = false

# Variable to track the active state of the menu item.
var is_active: bool = false
var menu: GMenuController

# Variable to determine if the menu item is in options mode.
var is_enumerable: bool = false

# Signals emitted when the menu item's active state changes or when it is submitted.
signal on_active_change(item: GMenuItem, is_active: bool)
signal on_submit(item: GLobbyWidget)

# Called when the node enters the scene tree for the first time.
func _ready():
	# Determine if the menu item is in options mode.
	is_enumerable = options.size() > 0
	mouse_entered.connect(_handle_mouse_entered)
	mouse_exited.connect(_handle_mouse_exited)
	pass # Replace with function body.

# Method to represent the menu item as a string.
func _to_string():
	return "MenuItem(name: %s,  value: %s)" % [name,  value]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Method to get the value as a float.
func get_float() -> float:
	return value

# Method to get the value as a boolean.
func get_bool() -> bool:
	return value > 0.5

func get_option():
	return options[option_index]

func get_value():
	if is_enumerable:
		return get_option()
	else:
		return value

# Method to navigate to the next option or increment the value.
func next_option():
	if has_options:
		if is_enumerable:
			option_index = tools.cycle_within_range(option_index + 1, 0, options.size() - 1)
		else:
			value = clampf(value + step, min_value, max_value)
	
	if menu.actions != null:
		menu.actions.handle_option_change(id, self)
	_after_option_updated()

# Method to navigate to the previous option or decrement the value.
func prev_option():
	if has_options:
		if is_enumerable:
			option_index = tools.cycle_within_range(option_index - 1, 0, options.size() - 1)
		else:
			value = clampf(value - step, min_value, max_value)
	
	if menu.actions != null:
		menu.actions.handle_option_change(id, self)
		
	_after_option_updated()

# Method to toggle the boolean value.
func toggle():
	value = 0 if get_bool() else 1

# Method to set the active state of the menu item.
func set_active(_is_active: bool):
	# Log the active state change.
	#dev.logd(TAG, "active change for %s, active: %s" % [self, _is_active])
	is_active = _is_active
	
	# Trigger animations based on the active state.
	if anim_player != null:
		if is_active:
			anim_player.play("select")
		else:
			anim_player.play("default")
	
	# Emit the on_active_change signal.
	on_active_change.emit(self, is_active)

# Method to submit the menu item.
func submit():
	# Log the submission.
	#dev.logd(TAG, "submitted %s" % self)
	# Emit the on_submit signal.
	on_submit.emit(self)
	
	if menu.actions != null:
		menu.actions.handle_submit(id, self)

func parse_value(_value):
	if has_options:
		if _value != null:
			if _value is float or _value is int:
				value = clampf(_value, min_value, max_value)
			if _value is String:
				var _index = options.find(_value)
				option_index =_index
		pass
	
	_after_option_updated()

func set_option_index(index: int):
	index = tools.cycle_within_range(index, 0, options.size())
	option_index = index
	
	_after_option_updated()

func _after_option_updated():
	pass

func _gui_input(event):
	if event is InputEventMouseButton:
		match event.button_index:
			1:
				if menu != null:
					menu.submit()
			4:
				if menu != null:
					menu.next_option()
			5:
				if menu != null:
					menu.prev_option()

func _handle_mouse_entered():
	_mouse_entered = true
	if menu != null:
		menu.select_item(self)

func _handle_mouse_exited():
	_mouse_entered = false
