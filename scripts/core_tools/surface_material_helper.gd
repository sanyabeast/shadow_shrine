
extends Node
class_name GSurfaceMaterialHelper
const TAG: String = "SurfaceMaterialHelper"

@export_subgroup("Override")
@export var override_enabled: bool = false
@export var override_meshes: Array[MeshInstance3D]
@export var override_material: Material
@export var override_copy_props: bool = false

@export_subgroup("Overlay")
@export var overlay_enabled: bool = false
@export var overlay_meshes: Array[MeshInstance3D]
@export var overlay_material: Material
@export var overlay_copy_props: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	apply_overlay()
	apply_override()

func apply_override():
	if override_enabled and override_material != null:
		for node in override_meshes:
			for surf_idx in node.mesh.get_surface_count():
				var _override_mat: ShaderMaterial = override_material.duplicate(true)
				var _source_mat = node.mesh.surface_get_material(surf_idx)
				
				if _source_mat is StandardMaterial3D:
					if override_copy_props:
						tools.copy_standard_props_to_shader(_source_mat, _override_mat)
						
					node.set_surface_override_material(surf_idx, _override_mat)

func apply_overlay():
	if overlay_enabled and overlay_material != null:
		for node in overlay_meshes:
			for surf_idx in node.mesh.get_surface_count():
				var _overlay_mat: ShaderMaterial = overlay_material.duplicate(true)
				
				if overlay_copy_props:
					var _source_mat: StandardMaterial3D = node.mesh.surface_get_material(surf_idx)
					tools.copy_standard_props_to_shader(_source_mat, _overlay_mat)
				
				node.material_overlay = _overlay_mat

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
