extends Node

class_name RApp

const TAG: String = "App"

@onready var data_index_path: String = ProjectSettings.get_setting("application/config/data_index")
var data: RDataIndex

# Called when the node enters the scene tree for the first time.
func _ready():
	data = load(data_index_path)
	dev.logd(TAG, "app ready, data index resource loaded: %s" % data)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
