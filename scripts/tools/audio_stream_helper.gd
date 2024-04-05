extends AudioStreamPlayer3D
class_name GAudioStreamHelper
var TAG: String = "AudioStringHelper"

@export_subgroup("# AudioStringHelper")
@export var seek_to_random_on_start: bool = false
@export var force_loop: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if seek_to_random_on_start and stream != null:
		seek(stream.get_length())
		
	finished.connect(_handle_finished)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _handle_finished():
	if force_loop:
		play()
