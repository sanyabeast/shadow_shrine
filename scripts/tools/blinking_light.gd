# Author: @sanyabeast
# Date: Mar. 2024

extends Light3D
class_name GBlinkLightHelper
const TAG: String = "BlinkLightHelper"

@export var min_energy: float = 0.5
@export var max_energy: float = 1

@export var update_interval: float = 0.1
@export var sinus_a_rate: float = 7
@export var sinus_b_rate: float = 17

var _sinus_a_offset: float = randf_range(0, PI)
var _sinus_b_offset: float = randf_range(0, PI)

var _timer_gate: GTimeGateHelper = GTimeGateHelper.new(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _timer_gate.check("update", update_interval):
		_update_energy(delta)

func _update_energy(delta):
	var sin_a = sin((game.time + _sinus_a_offset) * sinus_a_rate)
	var sin_b = sin((game.time + _sinus_b_offset) * sinus_b_rate)
	var alpha = ((sin_a + sin_b) + 2) / 4
	
	light_energy = lerpf(min_energy, max_energy, alpha)
	
	pass
