# Author: @sanyabeast
# Date: Feb. 2024

extends Node
class_name GTools
const TAG: String = "Tools"

var IS_DEBUG: bool = OS.is_debug_build()

enum EAxisRestrictionType {
	None,
	Axis4,
	Axis8
}

func logd(tag: String, data):
	if IS_DEBUG:
		print("[ %s ]: %s" % [tag, data])
	
func logr(tag: String, data):
	if IS_DEBUG:
		print("[ %s ]: [ ERROR! ] %s" % [tag, data])

# Recursive function to get all descendants with a specific substring in their names
func get_descendants_with_substring(root: Node, substring: String, matching_nodes: Array) -> Array:
	for child in root.get_children():
		if substring in child.name:
			matching_nodes.append(child)
		get_descendants_with_substring(child, substring, matching_nodes)
	return matching_nodes

func get_first_descendant_with_substring(root: Node, substring: String) -> Node:
	for child in root.get_children():
		if substring in child.name:
			return child
	return null

func spawn_object(template: PackedScene) -> Node:
	# Instance the scene
	var instance = template.instantiate()

	# Add the instance to the current scene tree
	get_scene().add_child(instance)

	# Optional: Set the position or other properties
	instance.global_position = Vector3(0, 0, 0)
	return instance

func spawn_object_and_replace(packed_scene: PackedScene, existing_object: Node) -> Node:
	# Check if the arguments are valid
	if packed_scene == null or existing_object == null:
		logd(TAG, "Invalid arguments passed to the function.")
		return

	# Instantiate the new object from the PackedScene
	var new_object = packed_scene.instantiate()

	# Assign transformations from the existing object to the new one
	new_object.transform = existing_object.transform

	# Add the new object to the same parent as the existing object
	if existing_object.get_parent():
		existing_object.get_parent().add_child(new_object)

	# Optionally, if you want to keep the same tree order, you can use this:
	# var index = existing_object.get_index()
	# existing_object.get_parent().add_child_below_node(existing_object, new_object)
	# existing_object.get_parent().move_child(new_object, index)

	# Queue the existing object for deletion
	existing_object.queue_free()
	return new_object

func get_scene() -> Node3D:
	return get_tree().current_scene

func get_random_element_from_array(arr: Array):
	if arr.size() == 0:
		return null
	var random_index = randi() % arr.size()
	return arr[random_index]

func get_random_key_from_dict(dict: Dictionary):
	if dict.is_empty():
		return null
		
	var keys = dict.keys()
	var random_index = randi() % keys.size()
	return keys[random_index]

func get_random_value_from_dict(dict: Dictionary):
	if dict.is_empty():
		return null
	var values = dict.values()
	var random_index = randi() % values.size()
	return values[random_index]

func random_bool() -> bool:
	return randi() % 2 == 0
	
func random_bool2(ratio: float) -> bool:
	return randf() < ratio

func change_material(node: MeshInstance3D, index: int, new_material: Material):
	if node and node is MeshInstance3D:
		node.set_surface_override_material(index, new_material)

func restrict_to_8_axis(raw_direction: Vector2) -> Vector2:
	return Vector2(
		round(raw_direction.x),
		round(raw_direction.y)
	).normalized()

func restrict_to_4_axis(raw_direction: Vector2) -> Vector2:
	return Vector2(
		1 if raw_direction.x > 0 else (-1 if raw_direction.x < 0 else 0),
		1 if raw_direction.y > 0 else (-1 if raw_direction.y < 0 else 0)
	).normalized()

func get_time()->float:
	return Time.get_ticks_msec() / 1000.0

func reload_scene():
	var current_scene = get_tree().current_scene
	get_tree().reload_current_scene()

func load_scene(scene_path: String):
	var tree: SceneTree = get_tree()
	tree.change_scene_to_file(scene_path)
	
func load_scene_packed(packed_scene: PackedScene):
	dev.logd("Tools", "prepare to load scene: %s" % packed_scene)
	var tree: SceneTree = get_tree()
	var result = tree.change_scene_to_packed(packed_scene)
	dev.logd("Tools", "LOADING PACKED SCENE, RESULT: %s" % result)

func move_toward_deg(from_angle: float, to_angle: float, delta: float)->float:
	return rad_to_deg(rotate_toward(deg_to_rad(from_angle + 180), deg_to_rad(to_angle + 180), deg_to_rad(delta))) - 180

func rotation_degrees_y_from_direction(direction: Vector3)->float:
	return rad_to_deg(atan2(direction.x, direction.z))
	
func rotation_degrees_y_from_direction_v2(direction: Vector2)->float:
	return rad_to_deg(atan2(direction.x, direction.y))
	
# returns the difference (in degrees) between angle1 and angle 2
# the given angles must be in the range [0, 360)
# the returned value is in the range (-180, 180]
func angle_difference(angle1, angle2):
	var diff = angle2 - angle1
	return diff if abs(diff) < 180 else diff + (360 * -sign(diff))

func angle_to_direction(angle_degrees: float) -> Vector3:
	# Convert degrees to radians
	var angle_radians = deg_to_rad(angle_degrees)

	# Calculate the direction vector
	var direction = Vector3(
		sin(angle_radians),
		0,  # Assuming rotation is around the y-axis in 3D
		cos(angle_radians)
	)

	return direction

func angle_to_direction_v2(angle_degrees: float) -> Vector2:
	# Convert degrees to radians
	var angle_radians = deg_to_rad(angle_degrees)

	# Calculate the direction vector
	var direction = Vector2(
		sin(angle_radians),
		cos(angle_radians)
	)

	return direction

func reverse_lerp(value: float, min_value: float, max_value: float) -> float:
	# Ensure that min is smaller than max to avoid division by zero
	if min_value >= max_value:
		return 0.0
	# Calculate the alpha (position value) based on the given value, min, and max
	var alpha = (value - min_value) / (max_value - min_value)
	# Clamp the alpha value between 0.0 and 1.0
	alpha = clampf(alpha, 0.0, 1.0)
	return alpha

func is_in_range(value: float, from: float, to: float, include: bool = true) -> bool:
	if include:
		return value >= from and value <= to 
	else:
		return value > from and value < to 

func repeat_substring(substring: String, times: int) -> String:
	var result: String = ""
	for i in range(times):
		result += substring
	return result

func to_v2(v3: Vector3) -> Vector2:
	return Vector2(v3.x, v3.z)

func sin_normalized(value: float) -> float:
	return (sin(value) + 1) / 2

func calculate_reflected_direction(direction: Vector3, normal: Vector3) -> Vector3:
	# Ensure both vectors are normalized
	direction = direction.normalized()
	normal = normal.normalized()
	
	# Calculate dot product of incident vector and surface normal
	var dot_product = direction.dot(normal)
	
	# Calculate reflected vector using the formula
	var reflected_direction = direction - 2 * dot_product * normal
	
	# Normalize the reflected vector
	reflected_direction = reflected_direction.normalized()
	
	# In a top-down game, the y-component should be zero
	reflected_direction.y = 0
	
	return reflected_direction

static func cycle_within_range(value, from_val, to):
	if value > to:
		value = from_val + (value - from_val) % (to - from_val + 1)
	if value < from_val:
		value = to - (from_val - value) % (to - from_val + 1) + 1
	return value

static func move_toward_color(from: Color, to: Color, speed: float) -> Color:
	return Color(
		move_toward(from.r, to.r, speed),
		move_toward(from.g, to.g, speed),
		move_toward(from.b, to.b, speed)
	)
	
static func array_unique(array):
	var unique = []

	for item in array:
		if not unique.has(item):
			unique.append(item)

	return unique
	
static func to_string_array(inp: Array) -> Array[String]:
	var output: Array[String] = []
	for item in inp:
		if item is String:
			output.append(item)
		else:
			output.append(item.to_string())
	return output

static func is_node_active(node) -> bool:
	return node != null and node.is_inside_tree() and node.is_visible_in_tree()
	
	
static func copy_standard_props_to_shader(source_mat: StandardMaterial3D, target_mat: ShaderMaterial):
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
	
static func is_point_inside_rect(point: Vector2, rect: Rect2) -> bool:
	return point.x > rect.position.x and point.y > rect.position.y and point.x < (rect.position.x + rect.size.x) and point.y < (rect.position.y + rect.size.y)
