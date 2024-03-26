# Author: @sanyabeast
# Date: Mar. 2024

extends GGameMode
class_name GGameModeLobby
const TAG: String = "GameModeLobby"

@export var demo_room: GRoomController
@export var bg_music_player: GAmbientPlaylistPlayer
@export var camera_anim_player: AnimationPlayer
@export var screen_fx: GScreenFX
@export var default_game_scene: String

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	game.start()
	
	for dir in world.directions_list:
		demo_room.doors_map[dir] = dir == world.EDirection.East
	
	demo_room.set_seed_offset(0)
	demo_room.initialize()
	demo_room.spawn_enemies()
	demo_room.close_doors(true)
	
	bg_music_player.play_mix()
	
	game.tasks.queue(self, "main_menu_fade_in", 0.5, screen_fx.fade_in.bind(2), null)
	game.tasks.queue(self, "doors", 2, null, demo_room.open_doors)
	
	game.resume()
	characters.enable_ai()
	
	#game.tasks.queue(self, "doors", 10, null, characters.kill_enemies)

func start_default_game():
	screen_fx.fade_out(0.5)
	app.tasks.queue(world.get_scene(), "load_game_level", 0.6, null, tools.load_scene.bind(default_game_scene))
