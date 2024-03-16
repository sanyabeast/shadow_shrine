# Author: @sanyabeast
# Date: Mar. 2024

extends GGameMode
class_name GGameModeMainMenue
const TAG: String = "GameModeMainMenu"

@export var demo_room: S2RoomController
@export var bg_music_player: GAmbientPlaylistPlayer
@export var camera_anim_player: AnimationPlayer
@export var screen_fx: GScreenFX
@export var default_game_scene: String

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	pass # Replace with function body.

	for dir in world.directions_list:
		demo_room.doors_map[dir] = true
	
	demo_room.set_seed_offset(0)
	demo_room.initialize(true)
	demo_room.open_doors(true)
	
	bg_music_player.play_mix()
	
	game.tasks.schedule(self, "main_menu_fade_in", 0.5, screen_fx.fade_in.bind(2))
	game.tasks.schedule(self, "doors", 2, demo_room.close_doors)
	
	game.resume()
	game.ai_enabled = true

func start_default_game():
	screen_fx.fade_out(0.5)
	app.tasks.schedule(world.get_scene(), "load_game_level", 0.6, tools.load_scene.bind(default_game_scene))
