# Author: @sanyabeast
# Date: Feb. 2024

@icon("res://assets/_dev/_icons/dotto-emoji-main-svg/Dotto Emoji125.svg")
extends Node3D
class_name GRoomController
const TAG: String = "RoomController"

enum EEnemyTypeListMergeMode {
	OVERWRITE,
	JOIN,
	JOIN_UNIQUE
}

@export_subgroup("# RoomController")
@export var player_spawn: Node3D

@export_subgroup("# RoomController ~ Enemies")
@export var enemy_types: Array[String] = []
@export var enemy_type_list_merge_mode:= EEnemyTypeListMergeMode.JOIN_UNIQUE

@export var doors_map: Dictionary = {
	world.EDirection.North: true,
	world.EDirection.East: true,
	world.EDirection.South: true,
	world.EDirection.West: true,
}

@export_subgroup("# RoomController ~ Referencies")
@export var content: Node3D
@export var doors_container: Node3D
@export var walls_gridmap: GridMap
@export var obstacles_gridmap: GridMap

@export_subgroup("# RoomController ~ Misc")
@export var auto_initialize: bool = false
@export var doors_opened: bool = false

@export_subgroup("# RoomController ~ Spots")
@export var enemy_spots: Node3D
@export var pickup_spots: Node3D
@export var chest_spots: Node3D

var door_controllers: Dictionary = {}

var _enemy_spots_list: Array[Node3D] = []
var _pickup_spots_list: Array[Node3D] = []
var _chest_spots_list: Array[Node3D] = []

# Randomness
var random: GRandHelper = GRandHelper.new()
var seed_offset: int = 0
		
# Called when the node enters the scene tree for the first time.

func _to_string():
	var pretty_door_map = {}
	for dir in world.directions_list:
		pretty_door_map[world.get_direction_pretty_name(dir)] = doors_map[dir]
	return "RoomController(name: %s, doors: %s)" % [name, pretty_door_map]

func _ready():
	if auto_initialize:
		random.set_seed(game.seed + seed_offset)
		initialize()
		
	if game.mode is GGameModeDefaultGame:
		match enemy_type_list_merge_mode:
			EEnemyTypeListMergeMode.OVERWRITE:
				pass
			EEnemyTypeListMergeMode.JOIN:
				enemy_types = game.mode.config.enemy_types + enemy_types
			EEnemyTypeListMergeMode.JOIN_UNIQUE:
				var unique_enemy_types = tools.to_string_array(
					tools.array_unique(game.mode.config.enemy_types + enemy_types)
				)
				enemy_types = unique_enemy_types
	
	name = "room"

func initialize():
	doors_container.global_position.y = 0
	
	_traverse(self)
	_init_spots()
	_apply_doors_map()
	
	world.set_sandbox(content)
	
	dev.logd(TAG, "room initialized: %s" % self)

func set_seed_offset(_seed_offset: int):
	seed_offset = _seed_offset
	random.set_seed(game.seed + seed_offset)
	dev.logd(TAG, "seed offset set to %s" % _seed_offset)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _traverse(node):
	# Call the callback function on the current node
	if node is GDoorController:
		assert(not door_controllers.has(node.direction), "there already door with direction %s exists in this room (%s)" % [node.direction, self.name])
		door_controllers[node.direction] = node
	
	# Recursively call this function on all children
	for child in node.get_children():
		_traverse(child)

func _init_spots():
	if enemy_spots != null:
		for spot in enemy_spots.get_children():
			if spot is Node3D:
				_enemy_spots_list.append(spot)
				
	if pickup_spots != null:
		for spot in pickup_spots.get_children():
			if spot is Node3D:
				_pickup_spots_list.append(spot)
	
	if chest_spots != null:
		for spot in chest_spots.get_children():
			if spot is Node3D:
				_chest_spots_list.append(spot)
	
	dev.logd(TAG, "room spots set up. found %s enemy spots, %s pickup spots, %s chest spots" % [_enemy_spots_list.size(), _pickup_spots_list.size(), _chest_spots_list.size()])

func spawn_enemies():
	for spot in _enemy_spots_list:
		_spawn_enemy(spot)

func _spawn_enemy(spot: Node3D):
	if enemy_types.size() > 0:
		pass
		var character_entry: GThesaurusEntry = game.thesaurus.get_one_item_from_list_by_rarity(
			GThesaurus.EThesaurusCategory.CHARACTER, 
			enemy_types,
			game.difficulty,
		)
		
		var prefab = character_entry.main_scene
		#var prefab: PackedScene = random.choice_from_array(config.enemies)
		dev.logd(TAG, "spawning enemy %s at %s ..." % [prefab, spot.global_position])
		var enemy: GCharacterController = prefab.instantiate()
		
		enemy.position = spot.global_position
		content.add_child(enemy)
		enemy.set_look_direction(tools.angle_to_direction_v2(randf_range(0, 360)))
		enemy.global_position = spot.global_position
		
	else:
		dev.logr(TAG, "unable to spawn enemys at specifiet spot: room config not congigured proprly")
	pass

func _apply_doors_map():
	for dir in world.directions_list:
		if doors_map[dir] == true:
			assert(door_controllers[dir] != null, "failed to initialize door at direction %s at room %s: no door controller found" % [dir, self])
			
			var cell_idx = world_to_gridmap(walls_gridmap, door_controllers[dir].global_position)
			walls_gridmap.set_cell_item(world_to_gridmap(walls_gridmap, door_controllers[dir].global_position), -1)
			
			door_controllers[dir].disable(true)
			door_controllers[dir].show()
		else:
			assert(door_controllers[dir] != null, "failed to initialize door at direction %s at room %s: no door controller found" % [dir, self])
			
			door_controllers[dir].disable(true)
			door_controllers[dir].hide()


func upload_saved_content(_content: Node3D):
	content.queue_free()
	content = _content
	world.set_sandbox(content)
	add_child(content)

func download_saved_content() -> Node3D:
	remove_child(content)
	return content
	
func world_to_gridmap(gridmap: GridMap, world_position: Vector3) -> Vector3i:
	var cell_x: int = 0
	var cell_z: int = 0
	
	var gridmap_global_pos: Vector3 = gridmap.global_position
	var cell_size: Vector3 = gridmap.cell_size
	
	# computing cell index for world coordinate
	var relative_position: Vector3 = world_position - gridmap_global_pos
	cell_x = floor(relative_position.x / cell_size.x)
	cell_z = floor(relative_position.z / cell_size.z)
	
	return Vector3i(cell_x, 0, cell_z)

func open_doors(skip_fx: bool = false):
	dev.logd(TAG, "opening all doors...")
	for key in door_controllers:
		door_controllers[key].enable(skip_fx)
	doors_opened = true	
	
func close_doors(skip_fx: bool = false):
	dev.logd(TAG, "closing all doors...")
	for key in door_controllers:
		door_controllers[key].disable(skip_fx)
	doors_opened = false	
