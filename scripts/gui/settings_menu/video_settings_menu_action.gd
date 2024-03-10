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
		"render_scale":
			result = app.get_render_scale()
		"render_sharpness":
			result = app.get_render_sharpness()
			
	dev.logd(TAG, "item %s intialized with value %s" % [id, result])
	return result

func _handle_option_change(id: String, item: S2MenuItem):
	match id:
		"render_scale":
			app.set_render_scale(item.value)
		"render_sharpness":
			app.set_render_sharpness(item.value)
