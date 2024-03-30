# Author: @sanyabeast
# Date: Mar. 2024

extends GGameMode
class_name GGameModeFreeroam
const TAG: String = "GameModeFreeroam"

@export_subgroup("# Game Mode Freeroam")
@export var freeroam_mode: GFreeroamMode
@export var bg_music_player: GAmbientPlaylistPlayer
@export var camera_anim_player: AnimationPlayer

@export var player: GCharacterController
@export var player_packed: PackedScene

var screen_fx: GScreenFX

func _prepare():
	super._prepare()
	game.start()
	screen_fx = widgets.controller.screen_fx
	
	widgets.controller.highlights.delay(1)
	characters.on_enemies_alive.connect(_handle_enemies_appear)
	characters.on_enemies_dead.connect(_handle_all_enemies_dead)
	characters.on_player_dead.connect(_handle_player_dead)
	
	_setup_player()
	game.resume()
	
	characters.enable_player()
	characters.enable_ai()
	
	screen_fx.fade_in((1))

func _process(delta):
	super._process(delta)
	
	if not game.is_over and not game.paused and Input.is_action_just_pressed("pause"):
		game.pause()
	
func _setup_player():
	if player == null:
		if characters.player != null:
			player = characters.player
		else:
			if player_packed != null:
				player = player_packed.instantiate()
				player.use_as_player = true
				add_child(player)
				characters.set_player(player)
			else:
				dev.logd(TAG, "failed to setup player: no player, no packed player, nothing")
		
#region: EVENT HANDLERS

func _handle_enemies_appear():
	dev.logd(TAG, "enemies appear")

func _handle_all_enemies_dead():
	dev.logd(TAG, "all enemies died")

func _handle_player_dead():
	if freeroam_mode != null:
		freeroam_mode.handle_player_dead()
	else:
		game.finish(false)
#endregion

func quit():
	app.load_main_menu_level()
