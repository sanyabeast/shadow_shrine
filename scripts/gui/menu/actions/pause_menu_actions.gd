extends S2MenuActions
class_name S2ActionsPauseMenu

@export var main_menu_scene: String

func _handle_submit(id: String, item: S2MenuItem):
	match id:
		"resume":
			game.resume()
		"quit":
			tools.load_scene(main_menu_scene)
