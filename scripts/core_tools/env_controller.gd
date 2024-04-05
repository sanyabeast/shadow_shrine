# Author: @sanyabeast
# Date: Mar. 2024


@icon("res://assets/_dev/_icons/dotto-emoji-main-svg/Dotto Emoji178.svg")
extends Node3D
class_name GEnvironmentController
var TAG: String = "EnvironmentController"

@export_subgroup("# EnvironmentController ~ Wind")
@export var use_wind_cycle: bool = false
@export var wind_direction_curve: Curve = Curve.new()
@export var wind_power_curve: Curve = Curve.new()
@export var wind_direction_cycle_duration: float = 41
@export var wind_power_cycle_duration: float = 17

@onready var wenv: WorldEnvironment = $WorldEnvironment
@onready var sun: DirectionalLight3D = $DirectionalLight3D

var _environment: Environment

# Called when the node enters the scene tree for the first time.
func _ready():
	_environment = wenv.environment
	_update_wenv_settings()
	if use_wind_cycle:
		assert(wind_power_curve != null and wind_direction_curve != null, "sett wind_power_curve and wind_direction_curve to use wind cycle")
	app.on_graphics_quality_preset_changed.connect(_update_wenv_settings)

func _process(delta):
	if use_wind_cycle and wind_direction_curve != null and wind_power_curve != null:
		_update_wind_cycle(delta)

func _update_wind_cycle(delta):
	var _dir = wind_direction_curve.sample_baked(fmod((game.time / wind_direction_cycle_duration), 1.))
	var _power = wind_power_curve.sample_baked(fmod((game.time / wind_power_cycle_duration), 1.))
	world.wind_direction = _dir
	world.wind_power = _power
	pass

func _update_wenv_settings():
	# ULTRA PRESET
	_environment.sdfgi_enabled = app.graphics_quality >= 3
	_environment.ssr_enabled = app.graphics_quality >= 3
	
	# HIGH PRESET
	_environment.ssil_enabled = app.graphics_quality >= 2
	_environment.ssao_enabled = app.graphics_quality >= 2
	
	# GENERIC FOG ONLY ON GRAPHICS BELOW MEDIUM INCLUDING
	_environment.fog_enabled = app.graphics_quality <= 1

	# MEDIUM PRESET
	_environment.adjustment_enabled = app.graphics_quality >= 1
	_environment.glow_enabled = app.graphics_quality >= 1
	
	
