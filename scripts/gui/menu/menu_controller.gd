extends Control

class_name S2MenuController
const TAG: String = "MenuController"

@export var id: String = ""
@export var items: Array[S2MenuItem]
@export var index: int = 0
@export var submenus: Array[S2MenuController]

var _active_submenu: S2MenuController

# Called when the node enters the scene tree for the first time.
func _ready():
	select(index)
	visibility_changed.connect(_handle_visibility_changed)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if visible and _active_submenu == null:
		if Input.is_action_just_pressed("ui_down"):
			select_next()
		if Input.is_action_just_pressed("ui_up"):
			select_prev()	
		if Input.is_action_just_pressed("ui_left"):
			prev_option()
		if Input.is_action_just_pressed("ui_right"):
			select_next()
		if Input.is_action_just_pressed("ui_accept"):
			submit()

func select(_index: int):
	_index = _index % items.size()
	index = _index
	
	dev.logd(TAG, "selected item index set to %s" % index )
	
	for i in items.size():
		if i != index:
			items[i].set_active(false)
		else:
			items[i].set_active(true)
			

func select_next():
	select(index + 1)
	
func select_prev():
	select(index - 1)

func next_option():
	items[index].next_option()

func prev_option():
	items[index].prev_option()

func submit():
	items[index].submit()

func _handle_visibility_changed():
	if visible:
		select(index)
	pass
	
func enter_submenu(id: String):
	var submenu = _get_submenu_with_id(id)
	_active_submenu = submenu
	
	for item in submenus:
		if item.id != id:
			item.visible = false
		else:
			item.visible = true

func _get_submenu_with_id(id: String) -> S2MenuController:
	var result
	for item in submenus:
		if item.id == id:
			result = item
			break
	return result
