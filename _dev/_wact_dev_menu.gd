# Author: @sanyabeast
# Date: Feb. 2024

extends GMenuActions

class_name GDevMenuActions

func _init_item(id: String):
	var result
	match id:
		"alter_seed":
			result = game.seed
		"ai_enabled":
			result = 1 if characters.ai_enabled else 0
		"game_speed":
			result = game.speed
			
	dev.logd(TAG, "item %s initialized with value %s" % [id, result])
	return result

func _handle_submit(id: String, item: GMenuItem):
	match id:
		"reload_current_scene":
			world.reload()
		"finish_game":
			game.finish(item.get_bool())
		"test_highlight_message":
			if widgets.controller != null and widgets.controller is GDefaultGameWidget:
				widgets.controller.highlights.delay(1)
				widgets.controller.highlights.show_message("Hello, World!", "this message will show up for 5 seconds", 5)
		"kill_all_enemies":
			game.tasks.queue(self, "_kill_all_enemies", 0.5, null, characters.kill_enemies.bind(0.1))
		"kill_player":
			game.tasks.queue(self, "_kill_player", 0.5, null, characters.kill_player)
		"test_impulse":
			if characters.player != null:
				game.tasks.queue(self, "_test_impulse", 0.5, null, characters.commit_impulse_to_all_enemies.bind(characters.player.global_position, 2))
			else:
				game.tasks.queue(self, "_test_impulse", 0.5, null, characters.commit_impulse_to_all_characters.bind(Vector3.ZERO, 2))
		
func _handle_option_change(id: String, item: GMenuItem):
	match id:
		"alter_seed":
			game.set_seed(round(item.value))
		"ai_enabled":
			characters.ai_enabled = item.get_bool()	
		"game_speed":
			game.speed = item.get_float()
		"set_player_immortal":
			characters.force_player_immortal = item.get_bool()
