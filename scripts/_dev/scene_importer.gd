@tool
extends EditorScenePostImport
class_name GImportScript

var override_alpha_material: ShaderMaterial = preload("res://_dev/materials/_smat_standard_material_alpha_emission.tres")
var override_material: ShaderMaterial = preload("res://_dev/materials/_smat_standard_material_emission.tres")

#var override_alpha_material: ShaderMaterial = preload("res://_dev/materials/_smat_retro_look_b.tres")
#var override_material: ShaderMaterial = preload("res://_dev/materials/_smat_retro_look_b.tres")

func _post_import(scene):
	_traverse(scene)
	return scene
	
func _traverse(node):
	if node != null:
		_process_node(node)
		for child in node.get_children():
			_traverse(child)

func _process_node(node: Object):
	if node is MeshInstance3D:
		for surf_idx in node.mesh.get_surface_count():
			var _source_mat: StandardMaterial3D = node.mesh.surface_get_material(surf_idx)
			var _target_mat: ShaderMaterial
			
			if _source_mat.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA:
				_target_mat = override_alpha_material.duplicate(true)
			elif _source_mat.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS:
				_target_mat = override_alpha_material.duplicate(true)	
			else:
				_target_mat = override_material.duplicate(true)
			
			_copy_from_standard_to_shader_standard(_source_mat, _target_mat)
			node.set_surface_override_material(surf_idx, _target_mat)
		
		pass

func _copy_from_standard_to_shader_standard(source_mat: StandardMaterial3D, target_mat: ShaderMaterial):
	target_mat.set_shader_parameter("albedo", source_mat.albedo_color)
	target_mat.set_shader_parameter("point_size", source_mat.point_size)
	target_mat.set_shader_parameter("roughness", source_mat.roughness)
	
	target_mat.set_shader_parameter("metallic_texture_channel", source_mat.metallic_texture_channel)
	target_mat.set_shader_parameter("specular", source_mat.metallic_specular)
	target_mat.set_shader_parameter("metallic", source_mat.metallic)
	target_mat.set_shader_parameter("emission", source_mat.emission)
	target_mat.set_shader_parameter("emission_energy", source_mat.emission_energy_multiplier)
	target_mat.set_shader_parameter("normal_scale", source_mat.normal_scale)
	
	target_mat.set_shader_parameter("uv1_scale", source_mat.uv1_scale)
	target_mat.set_shader_parameter("uv1_offset", source_mat.uv1_offset)
	target_mat.set_shader_parameter("uv2_scale", source_mat.uv2_scale)
	target_mat.set_shader_parameter("uv2_offset", source_mat.uv2_offset)
	
	target_mat.set_shader_parameter("texture_albedo", source_mat.albedo_texture)
	target_mat.set_shader_parameter("texture_metallic", source_mat.metallic_texture)
	target_mat.set_shader_parameter("texture_roughness", source_mat.roughness_texture)
	target_mat.set_shader_parameter("texture_normal", source_mat.normal_texture)
	target_mat.set_shader_parameter("texture_emission", source_mat.emission_texture)
	
	
	
	
	
	
	
	pass
