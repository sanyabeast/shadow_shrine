extends GMenuActions

func _handle_submit(id: String, item: GMenuItem):
	match id:
		"restart":
			world.reload()
		"quit":
			game.mode.quit_to_main_menu()
