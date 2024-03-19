extends Resource

class_name RSurfaceState

var shader_parameters: Dictionary = {}

func _init():
	update_shader_parameters()

func update_shader_parameters():
	assert(true, "override `update_shader_parameters`")
	pass
