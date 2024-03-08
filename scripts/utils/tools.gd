# Author: @sanyabeast
# Date: Feb. 2024

extends Node

class_name S2Tools

func logd(tag: String, data):
	print("[ %s ]: %s" % [tag, data])
	
func logr(tag: String, data):
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
		print("Invalid arguments passed to the function.")
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

func get_seeded_rng(seed_key: int) -> RandomNumberGenerator:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_key
	return rng

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

