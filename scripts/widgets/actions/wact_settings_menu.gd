# Author: @sanyabeast
# Date: Mar. 2024

extends GMenuActions
class_name GSettingsMenuActions

func _handle_submit(id: String, item: GMenuItem):
	match id:
		"gameplay_settings":
			game.resume()
		"audio_settings":
			menu.open_submenu("audio_settings_menu")
		"video_settings":
			menu.open_submenu("video_settings_menu")
