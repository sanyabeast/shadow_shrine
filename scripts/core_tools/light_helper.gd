# Author: @sanyabeast
# Date: Apr. 2024

@icon("res://assets/_dev/_icons/lamp_bulb_a.png")
extends Light3D
class_name GLightHelper

@export_subgroup("# LightHelper ~ Blinking")
@export var use_blinking: bool = false
@export var blinking_min_energy: float = 0.5
@export var blinking_max_energy: float = 1

@export var blinking_update_interval: float = 0.1
@export var blinking_sinus_a_rate: float = 7
@export var blinking_sinus_b_rate: float = 17

var blinking_sinus_a_offset: float = randf_range(0, PI)
var blinking_sinus_b_offset: float = randf_range(0, PI)

var _time_gate:= GTimeGateHelper.new(false)
var _shadows_initially_enabled: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	_shadows_initially_enabled = shadow_enabled
	app.on_shadows_quality_level_changed.connect(_update_quality_settings)
	call_deferred("_update_quality_settings")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if use_blinking:
		_update_blinking(delta)
	pass

func _update_blinking(delta):
	if _time_gate.check("blinking_update", blinking_update_interval):
		var sin_a = sin((game.time + blinking_sinus_a_offset) * blinking_sinus_a_rate)
		var sin_b = sin((game.time + blinking_sinus_b_offset) * blinking_sinus_b_rate)
		var alpha = ((sin_a + sin_b) + 2) / 4
		
		light_energy = lerpf(blinking_min_energy, blinking_max_energy, alpha)
	pass

func _update_quality_settings():
	var light = self
	if light is DirectionalLight3D:
		light.shadow_enabled = app.shadows_quality_level >= 1 and _shadows_initially_enabled
		
		if app.shadows_quality_level >= 1:
			light.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
			
		if app.shadows_quality_level >= 2:
			light.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
		
		light.directional_shadow_blend_splits = app.shadows_quality_level >= 3
		
	elif light is SpotLight3D:
		light.shadow_enabled = app.shadows_quality_level >= 2 and _shadows_initially_enabled
	elif light is OmniLight3D:
		light.shadow_enabled = app.shadows_quality_level >= 3 and _shadows_initially_enabled
		
		
	pass
