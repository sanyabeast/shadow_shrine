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
@export var player: S2Character
@export var player_packed: PackedScene
@export var main_menu_scene: String

var environment_node: Node3D
var architecture_node: Node3D
var characters_node: Node3D
var collectibles_node: Node3D

var _is_new_game_session: bool = true
var maze_generator: S2MazeGenerator = S2MazeGenerator.new()
var current_maze_cell: S2MazeGenerator.Cell = null

var current_room: S2RoomController
var EDirection = world.EDirection

var tasks: GTasker = GTasker.new(true)
var rooms_data: Dictionary = {}

# ambient sound
var _expore_ambience_mixer: GAmbientPlaylistPlayer
var _battle_ambience_mixer: GAmbientPlaylistPlayer

var screen_fx: GScreenFX
var random: GRandHelper = GRandHelper.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	pass # Replace with function body.

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
	
	reset()
	
	game.resume()

func _init_player():
	if player == null and player_packed != null:
		player = player_packed.instantiate()
		
	player.use_as_player = true
	add_child(player)
	player_manager.set_active(player)

func _setup_ambient_sound():
	_expore_ambience_mixer = GAmbientPlaylistPlayer.new(config.explore_playlist, 0)
	_battle_ambience_mixer = GAmbientPlaylistPlayer.new(config.battle_playlist, 0)
	
	_expore_ambience_mixer.name = "ExploreAmbienceMixer"
	_battle_ambience_mixer.name = "BattleAmbienceMixer"
	
	environment_node.add_child(_expore_ambience_mixer)
	environment_node.add_child(_battle_ambience_mixer)

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
	
func spawn_room(from_direction):
	game.disable_ai()
	
	print("spawining new room from maze cell %s " % current_maze_cell)
	
	from_direction = from_direction if from_direction != null else world.EDirection.North
	var oposite_direction = get_oposite_direction(from_direction)
		
	var room_template_index: int = 0
	var saved_content = null
	
	if rooms_data.has(current_maze_cell.index):
		room_template_index = rooms_data[current_maze_cell.index].room_template_index
	else:
		room_template_index = random.range(0, config.rooms.size())
		rooms_data[current_maze_cell.index] = {
			"room_template_index": room_template_index,
			"saved_content": null,
			"seed_offset": random.randi() % MAX_SEED_OFFSET_OF_ROOM
		}
	
	saved_content = rooms_data[current_maze_cell.index]["saved_content"]
	current_room = config.rooms[room_template_index].instantiate()
	
	for dir in world.directions_list:
		current_room.doors_map[dir] = not current_maze_cell.walls[dir]
	
	tools.get_scene().add_child(current_room)
	
	current_room.game_mode = self
	
	if saved_content != null:
		current_room.upload_saved_content(saved_content)
		
	world.dynamic_contant_container = current_room.content
	
	current_room.set_seed_offset(rooms_data[current_maze_cell.index]["seed_offset"])
	current_room.initialize(saved_content == null)
	
	if saved_content != null:
		current_room.open_doors(true)
	else:
		current_room.close_doors()
	
	var player_spawn = current_room
	
	if _is_new_game_session:
		player_spawn = current_room.player_spawn
		_is_new_game_session = false
	else:
		player_spawn = current_room.door_controllers[oposite_direction].player_spawn
		
	player_manager.teleport(player_spawn.global_position + Vector3(0, 2,0))
	
	_check_ambient_sound_mix()
	tasks.schedule(self, "enable_ai", 0.5, game.enable_ai)
	screen_fx.fade_in(ROOM_ENTER_SCREEN_FX_FADE_IN_DURATION)
	
func next_room(from_direction: world.EDirection, skip_fade: bool = false):
	if skip_fade:
		_next_room(from_direction)
	else:
		screen_fx.fade_out(ROOM_LEAVE_SCREEN_FX_FADE_OUT_DURATION)
		tasks.schedule(self, "next_room", ROOM_LEAVE_SCREEN_FX_FADE_OUT_DURATION * 1.1, _next_room.bind(from_direction))

func _next_room(from_direction: world.EDirection):
	if current_room != null:
		rooms_data[current_maze_cell.index]["saved_content"] = current_room.download_saved_content()
		current_room.queue_free()
	
	if current_maze_cell == null:
		current_maze_cell = maze_generator.start_cell
	else:
		current_maze_cell = current_maze_cell.get_sibling_to(from_direction)
		
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
	dev.logd(TAG, "player %s entered door %s" % [player_manager.name, world.get_direction_pretty_name(direction)])
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
	
	if not game.is_over and not game.paused and Input.is_action_just_pressed("pause"):
		game.pause()
			
	if game.timer_gate.check("check_door_state", 1):
		if not current_room.doors_opened and current_room.alive_enemies.size() == 0:
			current_room.open_doors()
		elif current_room.doors_opened and current_room.alive_enemies.size() > 0:
			current_room.close_doors()
	
	if game.timer_gate.check("check_camera_state", 1):
		if current_room.alive_enemies.size() == 0:
			camera_manager.current.target_zoom = 0
		else:
			camera_manager.current.target_zoom = 1
			
	if app.timer_gate.check("switch_ambient_music", 1):
		_check_ambient_sound_mix()

func _check_ambient_sound_mix():
	# has enemies
	if current_room.alive_enemies.size() > 0 and not _battle_ambience_mixer.is_playing:
		if AMBIENCE_SWAP_TRACK_ON_PLAYLIST_SWAP:
			_battle_ambience_mixer.next_track()
		_battle_ambience_mixer.play_mix(AMBIENCE_SHORT_FADE_TIME)
		
	if current_room.alive_enemies.size() > 0 and _expore_ambience_mixer.is_playing:
		_expore_ambience_mixer.pause_mix(AMBIENCE_SHORT_FADE_TIME)
		
	# no enemies
	if current_room.alive_enemies.size() == 0 and _battle_ambience_mixer.is_playing:
		_battle_ambience_mixer.pause_mix(AMBIENCE_LONG_FADE_TIME)
		
	if current_room.alive_enemies.size() == 0 and not _expore_ambience_mixer.is_playing:
		if AMBIENCE_SWAP_TRACK_ON_PLAYLIST_SWAP:
			_expore_ambience_mixer.next_track()
		_expore_ambience_mixer.play_mix(AMBIENCE_SHORT_FADE_TIME)

func quit_to_main_menu():
	screen_fx.fade_out(0.2)
	app.tasks.schedule(world.get_scene(), "load_main_menu_level", 0.4, tools.load_scene.bind(main_menu_scene))
