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
		"vblank_mode":
			result = app.get_vblank_mode()
		"shadows_quality":
			result = app.get_shadow_quality()	
	#dev.logd(TAG, "item %s intialized with value %s" % [id, result])
	return result

func _handle_submit(id: String, item: GMenuItem):
	match id:
		"quality_preset":
			app.set_graphics_quality(item.option_index)
		"vblank_mode":
			app.set_vnlank_mode(item.option_index)	
		"shadows_quality":
			app.set_shadow_quality(item.option_index)	

func _handle_option_change(id: String, item: GMenuItem):
	match id:
		"render_scale":
			app.set_render_scale(item.value)
		"render_sharpness":
			app.set_render_sharpness(item.value)
		
		
		
