# Author: @sanyabeast
# Date: Mar. 2024

@icon("res://assets/_dev/_icons/35b.png")
extends Node
class_name GMenuActions
const TAG: String = "MenuActions"

var menu: GMenuController

func initialize_items(items: Array[GMenuItem]):
	for item in items:
		if item.is_enumerable:
			var index = _init_item(item.id);
			if index == null:
				index = 1
			item.set_option_index(index)
		else:
			item.parse_value(_init_item(item.id)) 

func handle_submit(id: String, item: GMenuItem):
	dev.logd(TAG, "handling submit action for %s" % id)
	_handle_submit(id, item)

func handle_cancel():
	_handle_cancel()

func handle_option_change(id: String, item: GMenuItem):
	dev.logd(TAG, "handling option change for %s" % id)
	_handle_option_change(id, item)

func _handle_submit(id: String, item: GMenuItem):
	pass

func _handle_cancel():
	pass

func _handle_option_change(id: String, item: GMenuItem):
	pass

func _init_item(id: String):
	#dev.logd(TAG, "implement item initializer for %s" % id)
	return null
