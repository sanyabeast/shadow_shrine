# Author: @sanyabeast
# Date: Feb. 2024

# This script defines a menu controller for managing navigation and interaction with a menu system.

extends Control

class_name S2MenuController

# Constant tag for logging and identification purposes.
const TAG: String = "MenuController"

# Constant representing the maximum rate of menu item change.
const MAX_MENU_ITEM_CHANGE_RATE: float = 8
const ON_SHOW_SUBMIT_COOLDOWN: float = 0.05
const CANCEL_COOLDOWN: float = 0.05

# Exported variables for customization.
@export var id: String = ""
@export var anim_player: AnimationPlayer

@export_subgroup("Items")
@export var items: Array[S2MenuItem]
@export var index: int = 0

@export_subgroup("Submenus")
@export var submenus: Array[S2MenuController]
@export var active_submenu: S2MenuController = null
var parent_menu: S2MenuController = null

@export_subgroup("Actions")
@export var actions: S2MenuActions

@export_subgroup("Behaviour")
@export var close_submenu_on_hide: bool = true
@export var interactive: bool = true
@export var toggle_visibility_on_submenu: Array[Control] = []

@export_subgroup("sound")
@export var menu_sfx: RMenuSFX

var cooldown: S2CooldownManager = S2CooldownManager.new(false)
var _anim_on_close_submenu_to_show: String = ""
var _anim_on_close_close_itself: bool = false
var _anim_on_close_show_submenu: bool = false

var _audio_player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()

# Variable to store the currently active submenu.

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(actions != null, "actions not found at %s" % name)
	# Select the initial menu item.
	cooldown.start("submit_allowed", ON_SHOW_SUBMIT_COOLDOWN)
	cooldown.start("cancel_allowed", CANCEL_COOLDOWN)
	
	_audio_player.panning_strength = 0
	_audio_player.bus = "SFX"
	add_child(_audio_player)
	
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
	if visible and interactive and active_submenu == null:
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
	play_sound()
	
# Method to select the previous menu item.
func select_prev():
	select(index - 1)
	play_sound()

# Method to navigate to the next option within the currently selected menu item.
func next_option():
	items[index].next_option()
	play_sound(false, false, true)

# Method to navigate to the previous option within the currently selected menu item.
func prev_option():
	items[index].prev_option()
	play_sound(false, false, true)

# Method to submit the currently selected menu item.
func submit():
	if cooldown.ready("submit_allowed"):
		items[index].submit()
	
		play_sound(true)

func cancel():
	if cooldown.ready("cancel_allowed"):
		if actions:
			actions.handle_cancel()

		if parent_menu != null:
			if anim_player != null and anim_player.has_animation("close"):
				_anim_on_close_close_itself = true
				disable_interaction()
				play_animation("close")
			else:
				parent_menu.close_submenu()
				
		play_sound(false, true)
# Handler for the visibility changed signal.
func _handle_visibility_changed():
	# When the menu becomes visible, reselect the current index.
	if visible:
		cooldown.start("submit_allowed", ON_SHOW_SUBMIT_COOLDOWN)
		cooldown.start("cancel_allowed", CANCEL_COOLDOWN)
		select(index)
		
		if anim_player != null and anim_player.has_animation("open"):
			play_animation("open")
		else:
			enable_interaction()
	else:
		if close_submenu_on_hide:
			close_submenu()
			disable_interaction()
			play_animation("close", 1)
	pass

# Method to enter a submenu with a specific ID.
func open_submenu(id: String):
	if anim_player != null and anim_player.has_animation("close"):
		_anim_on_close_submenu_to_show = id
		_anim_on_close_show_submenu = true
		_anim_on_close_close_itself = false
		
		for item in toggle_visibility_on_submenu:
			item.visible = false
		
		disable_interaction()
		play_animation("close")
	else:
		_open_submenu(id)

func _open_submenu(id: String):
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
			
func close_submenu():
	active_submenu = null
	for item in submenus:
		item.visible = false
		
	for item in toggle_visibility_on_submenu:
		item.visible = true	
		
	if anim_player != null and anim_player.has_animation("open"):
		play_animation("open")
	else:
		enable_interaction()

# Method to get a submenu with a specific ID.
func get_submenu(id: String) -> S2MenuController:
	var result
	for item in submenus:
		if item.id == id:
			result = item
			break
	return result

func play_animation(name: String, progress: float = 0):
	if anim_player != null and anim_player.has_animation(name):
		anim_player.play(name)
		anim_player.seek(progress * anim_player.current_animation_length)

func enable_interaction():
	interactive = true
	
func disable_interaction():
	interactive = false

func handle_animation_finished(name: String):
	match name:
		"open":
			pass
			enable_interaction()
		"close":
			if _anim_on_close_close_itself:
				parent_menu.close_submenu()
				
			if _anim_on_close_show_submenu:
				_open_submenu(_anim_on_close_submenu_to_show)
				
			_anim_on_close_show_submenu = false
			_anim_on_close_close_itself = false
			
func play_sound(is_submit: bool = false, is_cancel: bool = false, is_alter: bool = false):
	if menu_sfx != null:
		var stream = menu_sfx.interaction_sound
		if is_submit:
			stream = stream if menu_sfx.submit_sound == null else menu_sfx.submit_sound
		if is_cancel:
			stream = stream if menu_sfx.cancel_sound == null else menu_sfx.cancel_sound
		if is_alter:
			stream = stream if menu_sfx.alter_sound == null else menu_sfx.alter_sound
		
		if stream != null:
			_audio_player.stream = stream
			_audio_player.play()
