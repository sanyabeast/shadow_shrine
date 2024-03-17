# Author: @sanyabeast
# Date: Mar. 2024

extends GMenuActions
class_name GVideoSettingsMenuAction

func _init_item(id: String):
	var result
	match id:
		"render_scale":
			result = app.get_render_scale()
		"render_sharpness":
			result = app.get_render_sharpness()
		"quality_preset":
			result = app.get_graphics_quality()
			
	dev.logd(TAG, "item %s intialized with value %s" % [id, result])
	return result

func _handle_option_change(id: String, item: GMenuItem):
	match id:
		"render_scale":
			app.set_render_scale(item.value)
		"render_sharpness":
			app.set_render_sharpness(item.value)
		"quality_preset":
			app.set_graphics_quality(item.option_index)
