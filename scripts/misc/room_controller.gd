extends Node3D

class_name S2RoomController

const TAG: String = "RoomController"

@export var player_spawn: Node3D
@export var doors_opened: bool = false

@export var doors_map: Dictionary = {
	world.EDirection.North: true,
	world.EDirection.East: true,
	world.EDirection.South: true,
	world.EDirection.West: true,
}

@export_subgroup("Referencies")
@export var doors_container: Node3D
@export var walls_gridmap: GridMap
@export var obstacles_gridmap: GridMap

@export_subgroup("Misc")
@export var auto_initialize: bool = false

var door_controllers: Dictionary = {}
var game_mode: S2GameModeDefaultGame

		
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

func initialize():
	doors_container.global_position.y = 0
	_traverse(self)
	_apply_doors_map()
	
	dev.logd(TAG, "room initialized: %s" % self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _traverse(node):
	# Call the callback function on the current node
	if node is S2DoorController:
		assert(not door_controllers.has(node.direction), "there already door with direction %s exists in this room (%s)" % [node.direction, self.name])
		door_controllers[node.direction] = node
		node.room_controller = self
	
	# Recursively call this function on all children
	for child in node.get_children():
		_traverse(child)


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
		close_doors()
	

func handle_player_exited_door_area(door: S2DoorController, player: S2Character):
	dev.logd(TAG, "player %s exited door %s" % [player.name, world.get_direction_pretty_name(door.direction)])
	game_mode.handle_player_exited_door_area(door.direction, player)
	
func open_doors():
	doors_opened = true
	
func close_doors():
	doors_opened = false
