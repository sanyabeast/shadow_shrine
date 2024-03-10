extends S2MenuActions


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _init_item(id: String):
	var result
	match id:
		"master_volume":
			result = app.get_volume()
		"music_volume":
			result = app.get_music_volume()
		"sfx_volume":
			result = app.get_sfx_volume()
			
	dev.logd(TAG, "item %s intialized with value %s" % [id, result])
	return result

func _handle_option_change(id: String, item: S2MenuItem):
	match id:
		"master_volume":
			app.set_volume(item.value)
		"music_volume":
			app.set_music_volume(item.value)
		"sfx_volume":
			app.set_sfx_volume(item.value)
