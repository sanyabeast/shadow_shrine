extends S2GameMode

class_name S2GameModeDefaultGame

const TAG = "GameModeDefaultGame"

@export var config: RGameLevelConfig

var environment_node: Node3D
var architecture_node: Node3D
var characters_node: Node3D
var collectibles_node: Node3D

var _is_new_game_session: bool = true
var maze_generator: S2MazeGenerator = S2MazeGenerator.new()
var current_maze_cell: S2MazeGenerator.Cell = null

var current_room: S2RoomController
var EDirection = world.EDirection

var tasks: S2TaskPlanner = S2TaskPlanner.new(true)

var rooms_data: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	pass # Replace with function body.

func prepare():
	super.prepare()
	
	environment_node = $Environment
	architecture_node = $Architecture
	characters_node = $Characters
	collectibles_node = $Collectibles
	
	reset()
	
	gui.set_mode(S2GUI.EMode.InGame)
	game.resume()

func reset():
	_is_new_game_session = true
	reset_maze()

func reset_maze():
	maze_generator.grid_size = 3
	maze_generator.sparseness = 0.4
	maze_generator.dead_ends_ratio = 0.7
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
		
	var room_template_index: int = 0
	
	if rooms_data.has(current_maze_cell.index):
		room_template_index = rooms_data[current_maze_cell.index].room_template_index
	else:
		room_template_index = randf_range(0, config.rooms.size())
		rooms_data[current_maze_cell.index] = {
			"room_template_index": room_template_index
		}
		
	current_room = config.rooms[room_template_index].instantiate()
	world.dynamic_contant_container = current_room.content
	
	for dir in world.directions_list:
		current_room.doors_map[dir] = not current_maze_cell.walls[dir]
	
	tools.get_scene().add_child(current_room)
	
	current_room.game_mode = self
	current_room.initialize()
	
	var player_spawn = current_room
	
	if _is_new_game_session:
		player_spawn = current_room.player_spawn
		_is_new_game_session = false
	else:
		player_spawn = current_room.door_controllers[oposite_direction].player_spawn
		
	player.teleport(player_spawn.global_position)
	
	#tasks.schedule(current_room, "open_all_doors", 3, current_room.open_doors)
	
	#current_room.open_doors()
	
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
	dev.logd(TAG, "player %s entered door %s" % [player.name, world.get_direction_pretty_name(direction)])
	next_room(direction)

func handle_player_exited_door_area(direction: world.EDirection, player: S2Character):
	dev.logd(TAG, "player %s exited door %s" % [player.name, world.get_direction_pretty_name(direction)])

func _process(delta):
	super._process(delta)
	
	tasks.update()
	
	dev.print_screen("maze_cell_xy", "maze cell x/y: %s/%s" % [current_maze_cell.x, current_maze_cell.y])
	dev.print_screen("maze_cell_index", "maze cell index: %s" % current_maze_cell.index)
	dev.print_screen("maze_cell_cat", "maze cell category: %s" % maze_generator.get_cell_category_pretty_name(current_maze_cell.category))
	dev.print_screen("room_alive_enemies", "alive enemies: %s" % [current_room.alive_enemies.size()])
	
	if Input.is_action_just_pressed("pause"):
		if game.paused:
			game.resume()
		else:
			game.pause()
			
	if game.timer_gate.check("check_room_is_cleaned", 1):
		if not current_room.doors_opened:
			if current_room.alive_enemies.size() == 0:
				current_room.open_doors()

