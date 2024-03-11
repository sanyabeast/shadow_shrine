extends S2GameMode

class_name S2GameModeMainMenue
const TAG: String = "GameModeMainMenu"

@export var demo_room: S2RoomController
@export var bg_music_player: S2AmbientSoundPlayer
@export var camera_anim_player: AnimationPlayer
@export var screen_fx: S2ScreenFX
@export var default_game_scene: String

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	pass # Replace with function body.

	for dir in world.directions_list:
		demo_room.doors_map[dir] = true
		
	demo_room.initialize(false)
	demo_room.open_doors(true)
	
	bg_music_player.play_mix()
	
	game.tasks.schedule(self, "main_menu_fade_in", 0.5, screen_fx.fade_in.bind(2))
	game.tasks.schedule(self, "doors", 2, demo_room.close_doors)
	
	game.resume()

func start_default_game():
	screen_fx.fade_out(0.5)
	app.tasks.schedule(world.get_scene(), "load_game_level", 0.6, tools.load_scene.bind(default_game_scene))
