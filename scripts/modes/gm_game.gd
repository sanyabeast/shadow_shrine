# Author: @sanyabeast
# Date: Feb. 2024

extends GGameMode

class_name GGameModeDefaultGame
const TAG = "GameModeDefaultGame"

const AMBIENCE_LONG_FADE_TIME: float = 2
const AMBIENCE_SHORT_FADE_TIME: float = 0.2
const AMBIENCE_SWAP_TRACK_ON_PLAYLIST_SWAP: bool = true

const ROOM_LEAVE_SCREEN_FX_FADE_OUT_DURATION: float = 0.25
const ROOM_ENTER_SCREEN_FX_FADE_IN_DURATION: float = 0.5

const MAX_SEED_OFFSET_OF_ROOM: int = 64

@export var config: RGameLevelConfig
@export var player: GCharacterController
@export var player_packed: PackedScene
@export var main_menu_scene: String

var environment_node: Node3D
var architecture_node: Node3D
var characters_node: Node3D
var collectibles_node: Node3D

var _is_new_game_session: bool = true
var maze_generator: GMazeGen = GMazeGen.new()
var current_maze_cell: GMazeGen.Cell = null

var active_room: GRoomController
var EDirection = world.EDirection

var tasks: GTasker = GTasker.new(true)
var room_states: Dictionary = {}

# ambient sound
var _expore_ambience_mixer: GAmbientPlaylistPlayer
var _battle_ambience_mixer: GAmbientPlaylistPlayer

var screen_fx: GScreenFX
var random: GRandHelper = GRandHelper.new()

#region: Lifecycle
func _ready():
	super._ready()
	pass # Replace with function body.

func _process(delta):
	super._process(delta)
	
	if not game.is_over and not game.paused and Input.is_action_just_pressed("pause"):
		game.pause()
		
	tasks.update()
	
	dev.print_screen("maze_cell_xy", "maze cell x/y: %s/%s" % [current_maze_cell.x, current_maze_cell.y])
	dev.print_screen("maze_cell_index", "maze cell index: %s" % current_maze_cell.index)
	dev.print_screen("maze_cell_cat", "maze cell category: %s" % maze_generator.get_cell_category_pretty_name(current_maze_cell.category))	

func prepare():
	super.prepare()
	
	game.start()
	random.set_seed(game.seed)
	
	screen_fx = widgets.controller.screen_fx
	environment_node = $Environment
	architecture_node = $Architecture
	characters_node = $Characters
	collectibles_node = $Collectibles
	
	_init_player()
	_setup_ambient_sound()
	
	widgets.controller.highlights.delay(1)
	
	characters.on_enemies_alive.connect(_handle_enemies_appear)
	characters.on_enemies_dead.connect(_handle_all_enemies_dead)
	
	reset()
	game.resume()

func _init_player():
	if player == null and player_packed != null:
		player = player_packed.instantiate()
		
	player.use_as_player = true
	add_child(player)
	characters.set_player(player)

func _setup_ambient_sound():
	_expore_ambience_mixer = GAmbientPlaylistPlayer.new(config.explore_playlist, 0)
	_battle_ambience_mixer = GAmbientPlaylistPlayer.new(config.battle_playlist, 0)
	
	_expore_ambience_mixer.name = "ExploreAmbienceMixer"
	_battle_ambience_mixer.name = "BattleAmbienceMixer"
	
	environment_node.add_child(_expore_ambience_mixer)
	environment_node.add_child(_battle_ambience_mixer)
#endregion

#region: Game
func reset():
	_is_new_game_session = true
	reset_maze()

func reset_maze():
	maze_generator.set_seed(game.seed)
	maze_generator.grid_size = 3
	maze_generator.sparseness = 0.1
	maze_generator.dead_ends_ratio = 0.5
	maze_generator.shortcuts_ratio = 0.5
	maze_generator.generate()
	print(maze_generator.cells)
	
	next_room(world.EDirection.North, true)
	
	print(current_maze_cell)
	
#endregion

#region: Rooms
func spawn_room(from_direction):
	dev.logd(TAG, "spawining new room from maze cell %s " % current_maze_cell)
	characters.disable_ai()
	
	from_direction = from_direction if from_direction != null else world.EDirection.North
	
	var is_player_first_time_in_the_room: bool = true
	var oposite_direction = world.get_oposite_direction(from_direction)
	var room_index: int = current_maze_cell.index	
	var room_template_index: int = -1
	var saved_content = null
	var room_state = _get_room_state(room_index)
	
	if room_template_index < 0:
		room_template_index = random.range(0, config.rooms.size())
		room_state["room_template_index"] = room_template_index
		
	#if room_states.has(current_maze_cell.index):
		#room_template_index = room_states[current_maze_cell.index].room_template_index
		#is_player_first_time_in_the_room = false
	#else:
		#room_template_index = random.range(0, config.rooms.size())
		#room_states[current_maze_cell.index] = {
			#"room_template_index": room_template_index,
			#"saved_content": null,
			#"seed_offset": random.randi() % MAX_SEED_OFFSET_OF_ROOM
		#}
	
	saved_content = room_state["saved_content"]
	active_room = config.rooms[room_template_index].instantiate()
	
	for dir in world.directions_list:
		active_room.doors_map[dir] = not current_maze_cell.walls[dir]
	
	active_room.game_mode = self
	active_room.set_seed_offset(room_states[current_maze_cell.index]["seed_offset"])
	
	if saved_content != null:
		active_room.upload_saved_content(saved_content)
		
	world.add_to_level(active_room)
	world.set_sandbox(active_room.content)
	
	active_room.initialize(saved_content == null)
	
	if saved_content != null:
		active_room.open_doors(true)
	else:
		active_room.close_doors()
	
	# playerr spawn
	var player_spawn = active_room
	
	if _is_new_game_session:
		player_spawn = active_room.player_spawn
		_is_new_game_session = false
	else:
		player_spawn = active_room.door_controllers[oposite_direction].player_spawn
		
	characters.teleport_player(player_spawn.global_position + Vector3(0, 2, 0))
	characters.enable_player()
	
	tasks.queue(self, "enable_ai", 0.5, null, characters.enable_ai)
	screen_fx.fade_in(ROOM_ENTER_SCREEN_FX_FADE_IN_DURATION)
	
	if is_player_first_time_in_the_room:
		widgets.controller.highlights.show_message("Room #%s '%s'" % [current_maze_cell.index, maze_generator.get_cell_category_pretty_name(current_maze_cell.category)], "kill all enemies")
	
func _get_room_state(room_index: int):
	if not room_states.has(room_index):
		room_states[room_index] = {
			"room_index": room_index,
			"room_template_index": -1,
			"saved_content": null,
			"seed_offset": room_index
		}
		
	return room_states.get(room_index)

func next_room(from_direction: world.EDirection, skip_fade: bool = false):
	if skip_fade:
		_next_room(from_direction)
	else:
		screen_fx.fade_out(ROOM_LEAVE_SCREEN_FX_FADE_OUT_DURATION)
		tasks.queue(self, "next_room", ROOM_LEAVE_SCREEN_FX_FADE_OUT_DURATION * 1.1, null, _next_room.bind(from_direction))

func _next_room(from_direction: world.EDirection):
	if active_room != null:
		room_states[current_maze_cell.index]["saved_content"] = active_room.download_saved_content()
		active_room.queue_free()
	
	if current_maze_cell == null:
		current_maze_cell = maze_generator.start_cell
	else:
		current_maze_cell = current_maze_cell.get_sibling_to(from_direction)
		
	spawn_room(from_direction)
	pass

#endregion

#region: EVENT HANDLERS
func handle_player_entered_door_area(direction: world.EDirection, player: GCharacterController):
	dev.logd(TAG, "player %s entered door %s" % [player.name, world.get_direction_pretty_name(direction)])
	next_room(direction)

func handle_player_exited_door_area(direction: world.EDirection, player: GCharacterController):
	dev.logd(TAG, "player %s exited door %s" % [player.name, world.get_direction_pretty_name(direction)])

func _handle_enemies_appear():
	dev.logd(TAG, "enemies appear")
	
	_battle_ambience_mixer.play_mix(AMBIENCE_SHORT_FADE_TIME)
	_battle_ambience_mixer.next_track()
	_expore_ambience_mixer.pause_mix(AMBIENCE_SHORT_FADE_TIME)
	
	if active_room.doors_opened:
		active_room.close_doors()

func _handle_all_enemies_dead():
	dev.logd(TAG, "all enemies died")
	
	_battle_ambience_mixer.pause_mix(AMBIENCE_LONG_FADE_TIME)
	_expore_ambience_mixer.play_mix(AMBIENCE_LONG_FADE_TIME)
	_expore_ambience_mixer.next_track()
	
	if not active_room.doors_opened:
		game.tasks.queue(self, "open-doors", 1, null, active_room.open_doors)

#endregion

#region: API
func quit_to_main_menu():
	screen_fx.fade_out(0.2)
	app.tasks.queue(world.get_scene(), "load_main_menu_level", 0.4, null, tools.load_scene.bind(main_menu_scene))
#endregion
