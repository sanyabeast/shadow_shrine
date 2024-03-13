# Author: @sanyabeast
# Date: Mar. 2024

extends Node
class_name S2MenuActions
const TAG: String = "MenuActions"

var menu: S2MenuController

func initialize_items(items: Array[S2MenuItem]):
	for item in items:
		item.parse_value(_init_item(item.id)) 

func handle_submit(id: String, item: S2MenuItem):
	dev.logd(TAG, "handling submit action for %s" % id)
	_handle_submit(id, item)

func handle_cancel():
	_handle_cancel()

func handle_option_change(id: String, item: S2MenuItem):
	dev.logd(TAG, "handling option change for %s" % id)
	_handle_option_change(id, item)

func _handle_submit(id: String, item: S2MenuItem):
	pass

func _handle_cancel():
	pass

func _handle_option_change(id: String, item: S2MenuItem):
	pass

func _init_item(id: String):
	dev.logd(TAG, "implement item initializer for %s" % id)
	return null
