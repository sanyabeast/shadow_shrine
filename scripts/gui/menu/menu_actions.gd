extends Node
class_name S2MenuActions
const TAG: String = "MenuActions"

var menu: S2MenuController

func handle_submit(id: String, item: S2MenuItem):
	dev.logd(TAG, "handling submit action for %s" % id)
	_handle_submit(id, item)

func _handle_submit(id: String, item: S2MenuItem):
	pass
