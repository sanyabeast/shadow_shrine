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

class GRoomState:
	var room_index: int
	var room_template: PackedScene
	var saved_content: Node3D
	var visited: bool = false
	var passed: bool = false
	var seed_offset: int
	var is_placeholder: bool = false

@export var config: RGameLevelConfig
@export var player: GCharacterController
@export var player_packed: PackedScene
@export var main_menu_scene: String
@export var maze_config: RMazeConfig = RMazeConfig.new()

var environment_node: Node3D

var is_first_room_in_game: bool = true
var maze_generator: GMazeGen = GMazeGen.new()
var current_maze_cell: GMazeGen.Cell = null

var active_room: GRoomController
var EDirection = world.EDirection

var tasks: GTasker = GTasker.new(true)
var room_states: Array[GRoomState] = []

# ambient sound
var _expore_ambience_mixer: GAmbientPlaylistPlayer
var _battle_ambience_mixer: GAmbientPlaylistPlayer

var screen_fx: GScreenFX
var random: GRandHelper = GRandHelper.new()


#region: API
func quit_to_main_menu():
	screen_fx.fade_out(0.2)
	app.tasks.queue(world.get_scene(), "load_main_menu_level", 0.4, null, tools.load_scene.bind(main_menu_scene))
#endregion

#region: Game
func reset():
	is_first_room_in_game = true
	random.set_seed(game.seed)
	_reset_maze()
	_prepare_room_states()
	_next_room(world.EDirection.North, true)

func _reset_maze():
	maze_generator.set_seed(game.seed)
	maze_generator.generate(maze_config)
#endregion

#region: Lifecycle
func _ready():
	super._ready()
	pass # Replace with function body.

func _process(delta):
	super._process(delta)
	
	if not game.is_over and not game.paused and Input.is_action_just_pressed("pause"):
		game.pause()
		
	tasks.update()
	
	if tools.IS_DEBUG:
		dev.print_screen("maze_stats", "maze (index / type / x:y ) %s / %s / %s:%s" % [
			current_maze_cell.index,
			maze_generator.get_cell_category_pretty_name(current_maze_cell.category),
			current_maze_cell.x, current_maze_cell.y
		])
		
func _prepare():
	super._prepare()
	game.start()
	
	screen_fx = widgets.controller.screen_fx
	widgets.controller.highlights.delay(1)
	characters.on_enemies_alive.connect(_handle_enemies_appear)
	characters.on_enemies_dead.connect(_handle_all_enemies_dead)
	characters.on_player_dead.connect(_handle_player_dead)
	
	_setup_player()
	_setup_ambient_sound()
	reset()
	game.resume()

func _setup_player():
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
	
	world.add_to_level(_expore_ambience_mixer)
	world.add_to_level(_battle_ambience_mixer)
#endregion

#region: Rooms
func _prepare_room_states():
	print(maze_generator.start_cell)
	for index in maze_config.size * maze_config.size:
		var cell: GMazeGen.Cell = maze_generator.get_cell_with_index(index)
		var state: GRoomState = GRoomState.new()
		
		if cell != null:
			dev.logd(TAG, "preapring room state for cell index %s, %s" % [index, cell])
			state.room_index = index
			state.seed_offset = random.randi() * MAX_SEED_OFFSET_OF_ROOM
			
			match cell.category:
				GMazeGen.ECellCategory.Start:
					state.room_template = random.choice_from_array(config.start_rooms)
				GMazeGen.ECellCategory.Default:
					state.room_template = random.choice_from_array(config.rooms)
				GMazeGen.ECellCategory.Shortcut:
					state.room_template = random.choice_from_array(config.rooms)
				GMazeGen.ECellCategory.Loop:
					state.room_template = random.choice_from_array(config.rooms)
				GMazeGen.ECellCategory.End:
					state.room_template = random.choice_from_array(config.end_rooms)
					
			#assert(state.room_template != null, "unabled to pick room_template for %s" % cell)
		else:
			state.is_placeholder = true
		
		room_states.append(state)
			
	pass 

func _get_current_room_state() -> GRoomState:
	return room_states[current_maze_cell.index]

func _spawn_room(from_direction):
	dev.logd(TAG, "spawining new room from maze cell %s " % current_maze_cell)
	characters.disable_ai()
	
	from_direction = from_direction if from_direction != null else world.EDirection.North
	var oposite_direction = world.get_oposite_direction(from_direction)
	var room_index: int = current_maze_cell.index	
	var room_state = _get_current_room_state()
	
	#region: Room setup
	print(current_maze_cell)
	active_room = room_state.room_template.instantiate()
	active_room.set_seed_offset(room_state.seed_offset)
	
	for dir in world.directions_list:
		active_room.doors_map[dir] = not current_maze_cell.walls[dir]
		
	world.add_to_level(active_room)
	world.set_sandbox(active_room.content)
	
	active_room.initialize()
	
	if room_state.saved_content == null:
		match current_maze_cell.category:
			GMazeGen.ECellCategory.Start:
				room_state.passed = true
			GMazeGen.ECellCategory.Default:
				active_room.spawn_enemies()
			GMazeGen.ECellCategory.Shortcut:
				active_room.spawn_enemies()
			GMazeGen.ECellCategory.End:
				active_room.spawn_enemies()
	else:
		active_room.upload_saved_content(room_state.saved_content)
	
	if room_state.passed == true:
		active_room.open_doors(true)
	else:
		active_room.close_doors()
	#endregion
	
	#region: Player setup
	if is_first_room_in_game:
		is_first_room_in_game = false
		var player_spawn = active_room.player_spawn
		characters.teleport_player(player_spawn.global_position + Vector3(0, 2, 0), player_spawn.global_rotation_degrees.y)
	else:
		var player_spawn = active_room.door_controllers[oposite_direction].player_spawn
		characters.teleport_player(player_spawn.global_position + Vector3(0, 2, 0))
		
	#endregion
	
	#region: Post load
	characters.enable_player()
	tasks.queue(self, "enable_ai", 0.5, null, characters.enable_ai)
	screen_fx.fade_in(ROOM_ENTER_SCREEN_FX_FADE_IN_DURATION)
	
	if not room_state.visited:
		match  current_maze_cell.category:
			GMazeGen.ECellCategory.Start:
				widgets.controller.highlights.show_message("%s" % [config.title], "")
			_:
				widgets.controller.highlights.show_message("Room #%s '%s'" % [current_maze_cell.index, maze_generator.get_cell_category_pretty_name(current_maze_cell.category)], "kill all enemies")
		room_state.visited = true
	#endregion
	
func _next_room(from_direction: world.EDirection, skip_fade: bool = false):
	if skip_fade:
		_next_room_main(from_direction)
	else:
		screen_fx.fade_out(ROOM_LEAVE_SCREEN_FX_FADE_OUT_DURATION)
		tasks.queue(self, "_next_room", ROOM_LEAVE_SCREEN_FX_FADE_OUT_DURATION * 1.1, null, _next_room_main.bind(from_direction))

func _next_room_main(from_direction: world.EDirection):
	if active_room != null:
		room_states[current_maze_cell.index].saved_content = active_room.download_saved_content()
		active_room.queue_free()
	
	if current_maze_cell == null:
		current_maze_cell = maze_generator.start_cell
	else:
		current_maze_cell = current_maze_cell.get_sibling_to(from_direction)
		
	_spawn_room(from_direction)
	pass

#endregion

#region: EVENT HANDLERS

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
	
	_get_current_room_state().passed = true
	
	if not active_room.doors_opened:
		game.tasks.queue(self, "open-doors", 1, null, active_room.open_doors)

func _handle_player_dead():
	game.finish(false)
#endregion

#region: Triggers
func _process_trigger(id: String, source: Node3D):
	match id:
		"player_enters_door":
			var door: GDoorController = source
			_when_player_enters_door(door)

func _when_player_enters_door(door: GDoorController):
	var direction:= door.direction
	dev.logd(TAG, "player %s entered door %s" % [player.name, world.get_direction_pretty_name(direction)])
	_next_room(direction)

#endregion
