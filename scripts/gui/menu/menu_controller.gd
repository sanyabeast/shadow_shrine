# Author: @sanyabeast
# Date: Feb. 2024

# This script defines a menu controller for managing navigation and interaction with a menu system.

extends Control

class_name S2MenuController

# Constant tag for logging and identification purposes.
const TAG: String = "MenuController"

# Constant representing the maximum rate of menu item change.
const MAX_MENU_ITEM_CHANGE_RATE: float = 4
const ON_SHOW_SUBMIT_COOLDOWN: float = 0.1
const CANCEL_COOLDOWN: float = 0.1

# Exported variables for customization.
@export var id: String = ""
@export var items: Array[S2MenuItem]
@export var index: int = 0
@export var actions: S2MenuActions

@export_subgroup("Submenus")
@export var submenus: Array[S2MenuController]
@export var content_to_hide_on_submenu: Array[Control] = []
@export var active_submenu: S2MenuController = null
var parent_menu: S2MenuController = null

@export_subgroup("Behaviour")
@export var close_submenu_on_hide: bool = true
var cooldown: S2CooldownManager = S2CooldownManager.new(false)

# Variable to store the currently active submenu.


# Called when the node enters the scene tree for the first time.
func _ready():
	assert(actions != null, "actions not found at %s" % name)
	# Select the initial menu item.
	cooldown.start("submit_allowed", ON_SHOW_SUBMIT_COOLDOWN)
	cooldown.start("cancel_allowed", CANCEL_COOLDOWN)
	
	select(index)
	
	actions.menu = self
	for item in items:
		item.menu = self
	# Connect the visibility changed signal to the corresponding handler.
	visibility_changed.connect(_handle_visibility_changed)
	actions.initialize_items(items)
	
	_init_submenus()
	
	pass # Replace with function body.

func _init_submenus():
	if active_submenu != null:
		open_submenu(active_submenu.id)
	else:
		close_submenu()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Process menu navigation inputs when the menu is visible and no active submenu is present.
	if visible and active_submenu == null:
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
		if Input.is_action_just_pressed("ui_cancel") or Input.is_action_just_pressed("pause"):
			cancel()

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
		assert(items[i] != null, "failed to parse item at index %s in menu %s" % [index, name])
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
	if cooldown.ready("submit_allowed"):
		items[index].submit()

func cancel():
	if cooldown.ready("cancel_allowed"):
		if actions:
			actions.handle_cancel()

		if parent_menu != null:
			parent_menu.close_submenu()

# Handler for the visibility changed signal.
func _handle_visibility_changed():
	# When the menu becomes visible, reselect the current index.
	if visible:
		cooldown.start("submit_allowed", ON_SHOW_SUBMIT_COOLDOWN)
		cooldown.start("cancel_allowed", CANCEL_COOLDOWN)
		select(index)
	else:
		if close_submenu_on_hide:
			close_submenu()
	pass

# Method to enter a submenu with a specific ID.
func open_submenu(id: String):
	# Retrieve the submenu with the specified ID.
	var submenu = get_submenu(id)
	
	assert(submenu != null, "submenu with id %s not found at %s" % [id, name])
	assert(submenu is S2MenuController, "submenu with id %s must be a S2MenuController type, found: %s at %s" % [id, submenu, name])

	dev.logd(TAG, "opening submenu with id: %s, found: %s" % [id, submenu])
	submenu.parent_menu = self
	active_submenu = submenu
	
	# Show or hide submenus based on the entered submenu.
	for item in submenus:
		if item.id != id:
			item.visible = false
		else:
			item.visible = true
	
	for item in content_to_hide_on_submenu:
		item.visible = false
			

func close_submenu():
	active_submenu = null
	for item in submenus:
		item.visible = false
		
	for item in content_to_hide_on_submenu:
		item.visible = true

# Method to get a submenu with a specific ID.
func get_submenu(id: String) -> S2MenuController:
	var result
	for item in submenus:
		if item.id == id:
			result = item
			break
	return result
