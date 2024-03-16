# Author: @sanyabeast
# Date: Feb. 2024

extends S2MenuActions

class_name S2DevMenuActions

func _init_item(id: String):
	var result
	match id:
		"alter_seed":
			result = game.seed
		"ai_enabled":
			result = 1 if game.ai_enabled else 0
		"game_speed":
			result = game.speed
			
	dev.logd(TAG, "item %s initialized with value %s" % [id, result])
	return result

func _handle_submit(id: String, item: S2MenuItem):
	match id:
		"reload_current_scene":
			world.reload()
		"finish_game":
			game.finish(item.get_bool())
		
func _handle_option_change(id: String, item: S2MenuItem):
	match id:
		"alter_seed":
			game.set_seed(round(item.value))
		"ai_enabled":
			game.ai_enabled = item.get_bool()	
		"game_speed":
			game.speed = item.get_float()
