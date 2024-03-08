# Author: @sanyabeast
# Date: Feb. 2024

# This script defines a menu controller for managing navigation and interaction with a menu system.

extends Control

class_name S2MenuController

# Constant tag for logging and identification purposes.
const TAG: String = "MenuController"

# Constant representing the maximum rate of menu item change.
const MAX_MENU_ITEM_CHANGE_RATE: float = 4

# Exported variables for customization.
@export var id: String = ""
@export var items: Array[S2MenuItem]
@export var index: int = 0
@export var submenus: Array[S2MenuController]
@export var actions: S2MenuActions

# Variable to store the currently active submenu.
var _active_submenu: S2MenuController

# Called when the node enters the scene tree for the first time.
func _ready():
	# Select the initial menu item.
	select(index)
	actions.menu = self
	for item in items:
		item.menu = self
	# Connect the visibility changed signal to the corresponding handler.
	visibility_changed.connect(_handle_visibility_changed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Process menu navigation inputs when the menu is visible and no active submenu is present.
	if visible and _active_submenu == null:
		if Input.is_action_just_pressed("ui_down"):
			select_next()
		if Input.is_action_just_pressed("ui_up"):
			select_prev()    
		if Input.is_action_just_pressed("ui_left"):
			prev_option()
		if Input.is_action_just_pressed("ui_right"):
			next_option()
			
		if Input.is_action_just_pressed("ui_accept"):
			submit()

# Method to select a specific menu item by index.
func select(_index: int):
	# Ensure the index is within valid bounds.
	if _index < 0:
		_index = items.size() - 1
	elif _index >= items.size():
		_index = 0
		
	index = _index
	
	# Log the selected item index.
	dev.logd(TAG, "selected item index set to %s" % index )
	
	# Set the active state for each menu item.
	for i in items.size():
		if i != index:
			items[i].set_active(false)
		else:
			items[i].set_active(true)

# Method to select the next menu item.
func select_next():
	select(index + 1)
	
# Method to select the previous menu item.
func select_prev():
	select(index - 1)

# Method to navigate to the next option within the currently selected menu item.
func next_option():
	items[index].next_option()

# Method to navigate to the previous option within the currently selected menu item.
func prev_option():
	items[index].prev_option()

# Method to submit the currently selected menu item.
func submit():
	items[index].submit()

# Handler for the visibility changed signal.
func _handle_visibility_changed():
	# When the menu becomes visible, reselect the current index.
	if visible:
		select(index)
	pass

# Method to enter a submenu with a specific ID.
func enter_submenu(id: String):
	# Retrieve the submenu with the specified ID.
	var submenu = _get_submenu_with_id(id)
	_active_submenu = submenu
	
	# Show or hide submenus based on the entered submenu.
	for item in submenus:
		if item.id != id:
			item.visible = false
		else:
			item.visible = true

# Method to get a submenu with a specific ID.
func _get_submenu_with_id(id: String) -> S2MenuController:
	var result
	for item in submenus:
		if item.id == id:
			result = item
			break
	return result
