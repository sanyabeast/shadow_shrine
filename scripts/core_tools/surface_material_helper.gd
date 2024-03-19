# Author: @sanyabeast
# Date: Mar. 2024

extends Node
class_name GSurfaceMaterialHelper
const TAG: String = "SurfaceMaterialHelper"

const DEFAULT_TRANSITION_DURATION: float = 0.3

@export var overlay_meshes: Array[MeshInstance3D]
@export var copy_props: bool = false
@export var overlay_material: ShaderMaterial

@export_subgroup("States")
@export var use_states: bool = false
@export var states: RSurfaceStates
@export var state_update_rate: float = 0

var _states: Dictionary
var current_state_id: String = ""
var current_state: RSurfaceState

var _overlay_mat_base: ShaderMaterial
var _overlay_materials: Array[ShaderMaterial] = []

var transition_duration: float = DEFAULT_TRANSITION_DURATION
var _transition_speed: float = 1 / DEFAULT_TRANSITION_DURATION
var _current_shader_parameters: Dictionary
var _target_shader_parameters: Dictionary
var _prev_transition_update_time: float = 0

var _timer_gate: GTimeGateHelper = GTimeGateHelper.new(true)

# Called when the node enters the scene tree for the first time.
func _ready():
	_overlay_mat_base = overlay_material.duplicate(true)
	
	if not copy_props:
		_overlay_materials.append(_overlay_mat_base)
	
	if use_states:
		_states = states.to_dict()
		_prev_transition_update_time = game.get_time()
		print("states ", _states)
		
	_apply_overlay()
		
	if use_states and states.list.size() > 0:
		enter_state(states.list[0].id)
 
func _apply_overlay():
	if overlay_material != null:
		for node in overlay_meshes:
			for surf_idx in node.mesh.get_surface_count():
				var _overlay_mat: ShaderMaterial
				
				if copy_props:
					_overlay_mat = _overlay_mat_base.duplicate(true)
					_overlay_materials.append(_overlay_mat)
				else:
					_overlay_mat = _overlay_mat_base
				
				if copy_props:
					var _source_mat: StandardMaterial3D = node.mesh.surface_get_material(surf_idx)
					tools.copy_standard_props_to_shader(_source_mat, _overlay_mat)
				
				node.material_overlay = _overlay_mat

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if use_states:
		_update_state(delta)
		
func _update_transition():
	var now = game.get_time()
	var delta: float = now - _prev_transition_update_time
	
	for key in _current_shader_parameters.keys():
		if _transition_speed > -1:
			if _current_shader_parameters[key] is float:
				_current_shader_parameters[key] = move_toward(
					_current_shader_parameters[key],
					_target_shader_parameters[key],
					_transition_speed * delta
				)
			elif _current_shader_parameters[key] is Color:
				_current_shader_parameters[key] = tools.move_toward_color(
					_current_shader_parameters[key],
					_target_shader_parameters[key],
					_transition_speed * delta
				)
		else:
			_current_shader_parameters = _target_shader_parameters
	_prev_transition_update_time = now
		
func _update_shader_properties(delta):
	for key in _current_shader_parameters.keys():
		for mat in _overlay_materials:
			mat.set_shader_parameter(key, _current_shader_parameters[key]) 
	pass

func _update_state(delta: float, force_update: bool = false):
	if force_update or state_update_rate < 0 or _timer_gate.check("update-state", 1 / state_update_rate):
		_update_transition()
		_update_shader_properties(delta)

func enter_state(state_id: String, transition_duration: float = DEFAULT_TRANSITION_DURATION):
	if use_states:
		current_state_id = state_id
		if _states.has(state_id):
			transition_duration = transition_duration
			_transition_speed = (1. / transition_duration) if transition_duration > 0 else -1
			print(_transition_speed)
			var _new_state_data: RSurfaceState = _states[state_id]
			current_state = _new_state_data
			_init_shader_parameter_states()
			_update_state(0, true)
			dev.logd(TAG, "state %s entered at %s" % [state_id, owner.name])
		else:
			print("surf state %s not found on %s" % [state_id, owner.name])
	
func _init_shader_parameter_states():
	current_state.update_shader_parameters()
	_target_shader_parameters = current_state.shader_parameters
	for key in _target_shader_parameters:
		if not _current_shader_parameters.has(key):
			_current_shader_parameters[key] = _target_shader_parameters[key]
	
