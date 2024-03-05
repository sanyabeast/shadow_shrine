extends Node3D

class_name S2RoomController

const TAG: String = "RoomController"

@export var config: RRoomConfig

@export var player_spawn: Node3D
@export var doors_opened: bool = false

@export var doors_map: Dictionary = {
	world.EDirection.North: true,
	world.EDirection.East: true,
	world.EDirection.South: true,
	world.EDirection.West: true,
}

@export_subgroup("Referencies")
@export var content: Node3D
@export var doors_container: Node3D
@export var walls_gridmap: GridMap
@export var obstacles_gridmap: GridMap

@export_subgroup("Misc")
@export var auto_initialize: bool = false

@export_subgroup("Spots")
@export var enemy_spots: Node3D
@export var pickup_spots: Node3D
@export var chest_spots: Node3D

var door_controllers: Dictionary = {}
var game_mode: S2GameModeDefaultGame

var _enemy_spots_list: Array[Node3D] = []
var _pickup_spots_list: Array[Node3D] = []
var _chest_spots_list: Array[Node3D] = []

var alive_enemies: Array[S2Character]
var all_enemies: Array[S2Character]
		
# Called when the node enters the scene tree for the first time.

func _to_string():
	var pretty_door_map = {}
	for dir in world.directions_list:
		pretty_door_map[world.get_direction_pretty_name(dir)] = doors_map[dir]
	return "RoomController(name: %s, doors: %s)" % [name, pretty_door_map]

func _ready():
	if auto_initialize:
		initialize()
	
	pass # Replace with function body.

func initialize(init_content = true):
	doors_container.global_position.y = 0
	_traverse(self)
	_init_spots()
	_apply_doors_map()
	
	if init_content:
		_apply_spots()
		#_spawn_enemies()
		
	dev.logd(TAG, "room initialized: %s" % self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game.timer_gate.check("_update_alive_enemies_list", 1):
		_update_alive_enemies_list()
	pass
	
func _update_alive_enemies_list():
	var dead_enemies_count: int = 0
	for e in alive_enemies:
		if e.is_dead:
			dead_enemies_count += 1
			
	if dead_enemies_count > 0:
		var newalive_enemies_list: Array[S2Character] = []
		for e in alive_enemies:
			if not e.is_dead:
				newalive_enemies_list.append(e)
	
		alive_enemies = newalive_enemies_list

func _traverse(node):
	# Call the callback function on the current node
	if node is S2DoorController:
		assert(not door_controllers.has(node.direction), "there already door with direction %s exists in this room (%s)" % [node.direction, self.name])
		door_controllers[node.direction] = node
		node.room_controller = self
	
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

func _apply_spots():
	for spot in _enemy_spots_list:
		_spawn_enemy(spot)

func _spawn_enemy(spot: Node3D):
	if config != null and config.enemies.size() > 0:
		var prefab: PackedScene = tools.get_random_element_from_array(config.enemies)
		dev.logd(TAG, "spawning enemy %s at %s ..." % [prefab, spot.global_position])
		var enemy: S2Character = prefab.instantiate()
		alive_enemies.append(enemy)
		all_enemies.append(enemy)
		content.add_child(enemy)
		enemy.global_position = spot.global_position
	else:
		dev.logr(TAG, "unable to spawn enemys at specifiet spot: room config not congigured proprly")
	pass

func _apply_doors_map():
	for dir in world.directions_list:
		if doors_map[dir] == true:
			assert(door_controllers[dir] != null, "failed to initialize door at direction %s at room %s: no door controller found" % [dir, self])
			var cell_idx = world_to_gridmap(walls_gridmap, door_controllers[dir].global_position)
			print("cell idx for %s door: %s" % [dir, cell_idx])
			walls_gridmap.set_cell_item(world_to_gridmap(walls_gridmap, door_controllers[dir].global_position), -1)
			door_controllers[dir].show()
		else:
			assert(door_controllers[dir] != null, "failed to initialize door at direction %s at room %s: no door controller found" % [dir, self])
			door_controllers[dir].hide()

func _spawn_enemies():
	for i in config.max_enemies:
		var pos = world.get_random_reachable_point_in_square(player_spawn.global_position, 32)
		var prefab: PackedScene = tools.get_random_element_from_array(config.enemies)
		var enemy: S2Character = prefab.instantiate()
		alive_enemies.append(enemy)
		content.add_child(enemy)
		enemy.global_position = pos
	pass
	
func upload_saved_content(_content: Node3D):
	content.queue_free()
	content = _content
	add_child(content)
	pass

func download_saved_content() -> Node3D:
	# trimming content to save mem?
	for enemy in all_enemies:
		if enemy != null:
			enemy.queue_free()
		
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
	
func handle_player_entered_door_area(door: S2DoorController, player: S2Character):
	if doors_opened:
		dev.logd(TAG, "player %s entered door %s at room" % [player.name, world.get_direction_pretty_name(door.direction), self])
		game_mode.handle_player_entered_door_area(door.direction, player)
		#close_doors()
	
func handle_player_exited_door_area(door: S2DoorController, player: S2Character):
	dev.logd(TAG, "player %s exited door %s" % [player.name, world.get_direction_pretty_name(door.direction)])
	game_mode.handle_player_exited_door_area(door.direction, player)
	

func open_doors(silent = false):
	dev.logd(TAG, "opening all doors...")
	for key in door_controllers:
		door_controllers[key].open(silent)
	doors_opened = true	
	
func close_doors(silent = false):
	dev.logd(TAG, "closing all doors...")
	for key in door_controllers:
		door_controllers[key].close(silent)
	doors_opened = false	
