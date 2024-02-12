extends Node3D

class_name S2CameraRig

# Called when the node enters the scene tree for the first time.
func _ready():
	print("camera rig: ready...")
	camera.add_camera(self)
	pass # Replace with function body.

func _exit_tree():
	camera.remove_camera(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
