extends GMenuActions

func _handle_submit(id: String, item: GMenuItem):
	match id:
		"restart":
			world.reload()
		"quit":
			if game.mode != null and game.mode is GGameModeDefaultGame:
				game.mode.quit_to_main_menu()
