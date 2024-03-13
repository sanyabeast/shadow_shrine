extends S2MenuActions

class_name S2DevMenuActions

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

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

func _handle_option_change(id: String, item: S2MenuItem):
	match id:
		"alter_seed":
			game.set_seed(round(item.value))
		"ai_enabled":
			game.ai_enabled = item.get_bool()	
		"game_speed":
			game.speed = item.get_float()
