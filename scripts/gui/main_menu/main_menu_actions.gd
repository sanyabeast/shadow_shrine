extends S2MenuActions
class_name S2ActionsMainMenu

@export var default_game_scene: String

func _handle_submit(id: String, item: S2MenuItem):
	match id:
		"start":
			tools.load_scene(default_game_scene)
		"settings":
			menu.open_submenu("settings_menu")
		"quit":
			app.quit()
