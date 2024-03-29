# Author: @sanyabeast
# Date: Mar. 2024

extends GMenuActions
class_name GPauseMenuActions

func _handle_submit(id: String, item: GMenuItem):
	match id:
		"resume":
			game.resume()
		"settings":
			menu.open_submenu("settings_menu")
		"quit":
			game.quit()
		"_dev_menu":
			menu.open_submenu("_dev_menu")
			
func _handle_cancel():
	game.resume()
