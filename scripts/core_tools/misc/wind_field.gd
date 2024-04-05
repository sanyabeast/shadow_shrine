
# Author: @sanyabeast
# Date: Mar. 2024

@icon("res://assets/_dev/_icons/dotto-emoji-main-svg/Dotto Emoji173.svg")
extends GPUParticlesAttractorVectorField3D
class_name GWindField
var TAG:= "WindField"


const ATTRACTOR_ROTATION_OFFSET:= 135.0

@export_subgroup("# Wind Field")
@export var wind_speed_max: float = 2
@export var wind_speed_curviness: float = 0.5
@export var wind_power: float = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	wind_power = clampf(
		lerpf(1., (tools.sin_normalized(game.time * 0.81) + tools.sin_normalized(game.time * 3.43)) / 2, wind_speed_curviness),
		0,
		1
	) * world.wind_power
	
	global_rotation_degrees.y = tools.move_toward_deg(global_rotation_degrees.y, world.wind_direction + ATTRACTOR_ROTATION_OFFSET, 360 * delta)
	
	strength = wind_power * wind_speed_max
