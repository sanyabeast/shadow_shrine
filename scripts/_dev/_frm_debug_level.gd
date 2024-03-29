extends GFreeroamMode


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if characters.player != null:
		world.wind_direction = characters.player.body_controller.global_rotation_degrees.y
