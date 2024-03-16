# Author: @sanyabeast
# Date: Mar. 2024

extends GMenuActions
class_name GLobbyMenuActions

func _handle_submit(id: String, item: GMenuItem):
	match id:
		"start":
			game.mode.start_default_game()
		"settings":
			menu.open_submenu("settings_menu")
		"quit":
			app.quit()
		"_dev_menu":
			menu.open_submenu("_dev_menu")
