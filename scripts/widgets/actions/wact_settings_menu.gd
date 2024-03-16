# Author: @sanyabeast
# Date: Mar. 2024

extends S2MenuActions
class_name S2SettingsMenuAction

func _handle_submit(id: String, item: S2MenuItem):
	match id:
		"gameplay_settings":
			game.resume()
		"audio_settings":
			menu.open_submenu("audio_settings_menu")
		"video_settings":
			menu.open_submenu("video_settings_menu")
