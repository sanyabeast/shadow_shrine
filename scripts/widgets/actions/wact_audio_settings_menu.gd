# Author: @sanyabeast
# Date: Mar. 2024

extends GMenuActions
class_name GAudioSettingsMenuActions

func _init_item(id: String):
	var result
	match id:
		"master_volume":
			result = app.get_volume()
		"music_volume":
			result = app.get_music_volume()
		"sfx_volume":
			result = app.get_sfx_volume()
			
	dev.logd(TAG, "item %s intialized with value %s" % [id, result])
	return result

func _handle_option_change(id: String, item: GMenuItem):
	match id:
		"master_volume":
			app.set_volume(item.value)
		"music_volume":
			app.set_music_volume(item.value)
		"sfx_volume":
			app.set_sfx_volume(item.value)
