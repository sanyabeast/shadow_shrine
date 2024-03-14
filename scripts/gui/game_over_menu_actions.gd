extends S2MenuActions

func _handle_submit(id: String, item: S2MenuItem):
	match id:
		"restart":
			world.reload()
		"quit":
			game.mode.quit_to_main_menu()
