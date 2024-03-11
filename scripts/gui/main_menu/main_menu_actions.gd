extends S2MenuActions
class_name S2ActionsMainMenu


func _handle_submit(id: String, item: S2MenuItem):
	match id:
		"start":
			game.mode.start_default_game()
		"settings":
			menu.open_submenu("settings_menu")
		"quit":
			app.quit()
