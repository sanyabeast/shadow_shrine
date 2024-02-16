extends Node3D

class_name S2RoomController

@export var north_door_enabled: bool = true
@export var east_door_enabled: bool = true
@export var south_door_enabled: bool = true
@export var west_door_enabled: bool = true

@export_category("Referencies")

@export var doors_container: Node3D

@export_subgroup("Doors")
@export var north_door: S2DoorHelper
@export var east_door: S2DoorHelper
@export var south_door: S2DoorHelper
@export var west_door: S2DoorHelper

@export_subgroup("Gridmaps")
@export var walls_gridmap: GridMap
@export var obstacles_gridmap: GridMap


func _prepare_doors():
	if north_door_enabled: 
		var cell_idx = world_to_gridmap(walls_gridmap, north_door.global_position)
		print("cell idx for north door: %s" % cell_idx)
		walls_gridmap.set_cell_item(world_to_gridmap(walls_gridmap, north_door.global_position), -1)
	else:
		north_door.hide()
	
	if east_door_enabled: 
		var cell_idx = world_to_gridmap(walls_gridmap, east_door.global_position)
		print("cell idx for east door: %s" % cell_idx)
		walls_gridmap.set_cell_item(world_to_gridmap(walls_gridmap, east_door.global_position), -1)
	else:
		east_door.hide()
	
	if south_door_enabled: 
		var cell_idx = world_to_gridmap(walls_gridmap, south_door.global_position)
		print("cell idx for south door: %s" % cell_idx)
		walls_gridmap.set_cell_item(world_to_gridmap(walls_gridmap, south_door.global_position), -1)	
	else:
		south_door.hide()
	
	if west_door_enabled: 
		var cell_idx = world_to_gridmap(walls_gridmap, west_door.global_position)
		print("cell idx for west door: %s" % cell_idx)
		walls_gridmap.set_cell_item(world_to_gridmap(walls_gridmap, west_door.global_position), -1)
	else:
		west_door.hide()
		
	north_door.room_controller = self;
	east_door.room_controller = self;
	south_door.room_controller = self;
	west_door.room_controller = self;
	
	north_door.direction = S2WorldManager.EDirection.North;
	east_door.direction = S2WorldManager.EDirection.East;
	south_door.direction = S2WorldManager.EDirection.South;
	west_door.direction = S2WorldManager.EDirection.West;
		
# Called when the node enters the scene tree for the first time.
func _ready():
	doors_container.global_position.y = 0
	_prepare_doors()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

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
	
func handle_player_entered_door_area(door: S2DoorHelper, player: S2Character):
	print("player %s entered door %s" % [player.name, door.direction])

func handle_player_exited_door_area(door: S2DoorHelper, player: S2Character):
	print("player %s exited door %s" % [player.name, door.direction])
