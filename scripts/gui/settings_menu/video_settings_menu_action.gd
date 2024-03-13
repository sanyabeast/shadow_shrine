# Author: @sanyabeast
# Date: Mar. 2024

extends S2MenuActions
class_name S2VideoSettingsMenuAction

func _init_item(id: String):
	var result
	match id:
		"render_scale":
			result = app.get_render_scale()
		"render_sharpness":
			result = app.get_render_sharpness()
			
	dev.logd(TAG, "item %s intialized with value %s" % [id, result])
	return result

func _handle_option_change(id: String, item: S2MenuItem):
	match id:
		"render_scale":
			app.set_render_scale(item.value)
		"render_sharpness":
			app.set_render_sharpness(item.value)
