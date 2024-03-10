extends S2GameMode

class_name S2GameModeMainMenue
const TAG: String = "GameModeMainMenu"

@export var demo_room: S2RoomController
@export var bg_music_player: S2AmbientSoundPlayer
@export var camera_anim_player: AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

	for dir in world.directions_list:
		demo_room.doors_map[dir] = true
		
	demo_room.initialize(false)
	demo_room.open_doors(true)
	
	bg_music_player.play_mix()
	app.tasks.schedule(self, "doors", 1, demo_room.close_doors)
	
	game.resume()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass