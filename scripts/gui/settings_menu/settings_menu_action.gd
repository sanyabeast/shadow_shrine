extends S2MenuActions

class_name S2SettingsMenuAction

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _handle_submit(id: String, item: S2MenuItem):
	match id:
		"gameplay_settings":
			print("action: %s" % id)
			game.resume()
		"audio_settings":
			print("action: %s" % id)
			game.resume()
		"video_settings":
			print("action: %s" % id)
			game.resume()
