extends S2GameMode

class_name S2GameModeDefaultGame 

const TAG = "GameModeDefaultGame: "

@export var config: RGameLevelConfig

var environment_node: Node3D
var architecture_node: Node3D
var characters_node: Node3D
var collectibles_node: Node3D

var is_new_run: bool = true
var maze_generator: S2MazeGenerator = S2MazeGenerator.new()
var current_maze_cell: S2MazeGenerator.Cell = null

var current_room: S2RoomController
var EDirection = world.EDirection

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	pass # Replace with function body.

func prepare():
	environment_node = $Environment
	architecture_node = $Architecture
	characters_node = $Characters
	collectibles_node = $Collectibles
	
	reset_game_mode()
	
	super.prepare()

func reset_game_mode():
	reset_maze()
	spawn_room(null)

func reset_maze():
	maze_generator.grid_size = 4
	maze_generator.sparseness = 0.1
	maze_generator.dead_ends_ratio = 0.8
	maze_generator.shortcuts_ratio = 0.1
	maze_generator.generate()
	print(maze_generator.cells)
	
	next_room(world.EDirection.North)
	
	print(current_maze_cell)

	
func spawn_room(from_direction):
	print("spawining new room from maze cell %s " % current_maze_cell)
	
	if current_room != null:
		print("destroying current room")
		current_room.queue_free()
		
	from_direction = from_direction if from_direction != null else world.EDirection.North
	var oposite_direction = get_oposite_direction(from_direction)
	var spawn_position: Vector3 = Vector3(0,0,0)
		
	current_room = tools.get_random_element_from_array(config.rooms).instantiate()
	
	for dir in world.directions_list:
		current_room.doors_map[dir] = not current_maze_cell.walls[dir]
	
	# if not is_new_run:
	#	current_room.doors_map[oposite_direction] = true
	
	print(current_room)
	
	tools.get_scene().add_child(current_room)
	
	current_room.game_mode = self
	current_room.initialize()
	
	player.teleport(current_room.player_spawn.global_position)
	
	current_room.open_doors()
	
	#if not is_new_run:
		#var spawn_doorway = current_room.doors[oposite_direction]
		#
		#if spawn_doorway == null:
			#print(TAG + "picking random doorway")
			#spawn_doorway = tools.get_random_element_from_array(current_room.doorways_list)
		#
		#if spawn_doorway != null:
			#print(spawn_doorway)
			#spawn_doorway.is_player_in = true
			#spawn_position = spawn_doorway.get_player_spawn().global_position
			#print(TAG + "door direction: %s, oposite direction: %s" % [from_direction, oposite_direction])
		#else:
			#print(TAG + "unable to pick spawn_doorway for direction %s" % from_direction)
	#else:
		#is_new_run = false
	
	#player_manager.teleport(spawn_position)
	
	
func next_room(from_direction: world.EDirection):
	if current_room != null:
		current_room.queue_free()
	
	print("next_room: current room - %s" % current_maze_cell)
	
	if current_maze_cell == null:
		current_maze_cell = maze_generator.start_cell
	else:
		current_maze_cell = current_maze_cell.get_sibling_to(from_direction)
	
	print("sib cell: ", current_maze_cell.get_sibling_to(world.EDirection.North))
	print("sib cell: ", current_maze_cell.get_sibling_to(world.EDirection.East))
	print("sib cell: ", current_maze_cell.get_sibling_to(world.EDirection.South))
	print("sib cell: ", current_maze_cell.get_sibling_to(world.EDirection.West))
	
	print("switching to the next room from direction: %s, new maze cell: %s" % [from_direction, current_maze_cell])
	spawn_room(from_direction)
	pass


func get_oposite_direction(direcrion: world.EDirection) -> world.EDirection:
	match direcrion:
		world.EDirection.North:
			return world.EDirection.South
		world.EDirection.East:
			return world.EDirection.West
		world.EDirection.South:
			return world.EDirection.North
		world.EDirection.West:
			return world.EDirection.East
		_:
			return world.EDirection.East

func handle_player_entered_door_area(direction: world.EDirection, player: S2Character):
	print("player %s entered door %s" % [player.name, direction])
	next_room(direction)

func handle_player_exited_door_area(direction: world.EDirection, player: S2Character):
	print("player %s exited door %s" % [player.name, direction])

func _process(delta):
	dev.print_screen("maze_cell_xy", "maze cell x/y: %s/%s" % [current_maze_cell.x, current_maze_cell.y])
	dev.print_screen("maze_cell_index", "maze cell index: %s" % current_maze_cell.index)
	dev.print_screen("maze_cell_cat", "maze cell category: %s" % current_maze_cell.category)
