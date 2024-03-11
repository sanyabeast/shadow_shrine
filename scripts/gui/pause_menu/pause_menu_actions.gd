extends S2MenuActions
class_name S2ActionsPauseMenu


func _handle_submit(id: String, item: S2MenuItem):
	match id:
		"resume":
			game.resume()
		"settings":
			menu.open_submenu("settings_menu")
		"quit":
			game.mode.quit_to_main_menu()
			
func _handle_cancel():
	game.resume()
