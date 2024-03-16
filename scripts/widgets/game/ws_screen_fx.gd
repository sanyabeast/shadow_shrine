# Author: @sanyabeast
# Date: Mar. 2024

extends Control

class_name GScreenFX
const TAG: String = "ScreenFX"

@onready var anim_player = $AnimationPlayer
@export var start_from_black: bool = true
@export var dark_fader: CanvasItem

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	if start_from_black:
		show_dark_fader()
	else:
		anim_player.play("clear")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func handle_animation_finished(name: String):
	dev.logd(TAG, "animation `%s` finished" % name)

func get_duration(anim_name = null) -> float:
	var result: float = 0
	if anim_name == null:
		result = anim_player.current_animation_length * absf(anim_player.speed_scale)
	else:
		var anim: Animation = anim_player.get_animation(anim_name)
		result = anim.length
	
	return result
	
func show_dark_fader():
	dark_fader.visible = true
	dark_fader.modulate = Color.WHITE
	pass
	
func fade_out(duration: float = 1, light: bool = false):
	if duration == 0:
		show_dark_fader()
	else:
		anim_player.speed_scale = 1 / duration
		if light:
			anim_player.play("fade_out_light")
		else:
			anim_player.play("fade_out_dark")
		
func fade_in(duration: float = 1, light: bool = false):
	anim_player.speed_scale = 1 / duration
	if light:
		anim_player.play("fade_in_light")
	else:
		anim_player.play("fade_in_dark")

func fade_out_alt(duration: float = 1, light: bool = false):
	anim_player.speed_scale = 1 / duration
	anim_player.play("fade_out_dark_alt")
		
func fade_in_alt(duration: float = 1, light: bool = false):
	anim_player.speed_scale = 1 / duration
	anim_player.play("fade_in_dark_alt")
