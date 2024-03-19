# Author: @sanyabeast
# Date: Mar. 2024

extends WorldEnvironment

class_name GWorldEnvironmentHelper
const TAG: String = "WorldEnvironmentHelper"

# Called when the node enters the scene tree for the first time.
func _ready():
	_update_settings()
	app.on_graphics_quality_preset_changed.connect(_update_settings)
	pass # Replace with function body.

func _update_settings():
	# HIGH PRESET
	environment.sdfgi_enabled = app.graphics_quality >= 3
	environment.ssr_enabled = app.graphics_quality >= 3
	environment.volumetric_fog_enabled = app.graphics_quality >= 3
	
	# GENERIC FOG ONLY ON GRAPHICS BELOW MEDIUM INCLUDING
	environment.fog_enabled = app.graphics_quality <= 2
	
	# MEDIUM PRESET
	environment.ssil_enabled = app.graphics_quality >= 2
	environment.ssao_enabled = app.graphics_quality >= 2

	# LOW PRESET
	environment.adjustment_enabled = app.graphics_quality >= 1
	environment.glow_enabled = app.graphics_quality >= 1
