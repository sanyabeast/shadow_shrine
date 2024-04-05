# Author: @sanyabeast
# Date: Mar. 2024

@icon("res://assets/_dev/_icons/46.png")
extends Node3D
class_name GGizmo

@export_subgroup("# Gizmo")
@export var remove_at_production: bool = false
@export var ingame_scale: float = 1

@export_subgroup("# Gizmo ~ States")
@export var use_states: bool = false
@export_placeholder("Active state name") var state: String = ""
## List of meshes which ShaderMaterial "albedo" parameter will be altered with state color
@export var meshes: Array[MeshInstance3D] = []
## Dictionary<String, Color>
@export var states: Dictionary = {
	"default": Color.MAGENTA,
	"disabled": Color.SLATE_GRAY,
	"active": Color.DARK_ORANGE
}

var _materials: Array[ShaderMaterial] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	scale = scale * ingame_scale
	if not tools.IS_DEBUG and remove_at_production:
		queue_free()
		
	if use_states and states.size() > 0:
		for mesh in meshes:
			for index in mesh.mesh.get_surface_count():
				var mat = mesh.mesh.surface_get_material(index)
				if mat is ShaderMaterial:
					#mat = mat.duplicate()
					#mesh.mesh.surface_set_material(index, mat)
					_materials.append(mat)
					
		if state == "":
			state = states.keys()[0]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	visible = dev.show_debug_graphics
	if visible and use_states:
		_update_state()
	pass

func _update_state():
	if states.has(state):
		var color: Color = states[state]
		for mat in _materials:
			mat.set_shader_parameter("albedo", color)
