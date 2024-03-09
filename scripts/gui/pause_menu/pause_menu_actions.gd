extends S2MenuActions
class_name S2ActionsPauseMenu

@export var main_menu_scene: String

func _handle_submit(id: String, item: S2MenuItem):
	match id:
		"resume":
			game.resume()
		"settings":
			menu.open_submenu("settings_menu")
		"quit":
			tools.load_scene(main_menu_scene)
			
func _handle_cancel():
	game.resume()
