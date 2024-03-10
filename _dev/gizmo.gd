extends Node3D

@export var remove_at_production: bool = false
@export var ingame_scale: float = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	scale = scale * ingame_scale
	if not tools.IS_DEBUG and remove_at_production:
		queue_free()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	visible = dev.show_debug_graphics
	pass
