# Author: @sanyabeast
# Date: Mar. 2024

extends Control
class_name GWidgetLabel
const TAG: String = "WidgetLabel"

enum EValueFormatType {
	NONE,
	LOCALIZED_TEXT,
	PERCENTS_FROM_PROGRESS,
	PERCENTS_FROM_PROGRESS_SIGNED,
	IX5_FROM_PROGRESS,
	IX10_FROM_PROGRESS,
	LX5_FROM_PROGRESS,
	LX10_FROM_PROGRESS,
	FRACTION,
	YES_NO_FROM_PROGRESS,
	INTEGER,
	FLOAT2,
	VALUE_SLASH_MAX_INTEGER,
	VALUE_SLASH_MAX_FLOAT,
	CUSTOM
}

enum EOperatingMode {
	TEXT,
	FLOAT
}

@export_category("Rendering")
@export_subgroup("Textual")
@export var use_textual_rendering: bool = true
@export var render_label: Label
@export var use_template: bool = false
@export var template: String = "< {content} >"

@export_subgroup("Animated")
@export var use_animated_rendering: bool = false
@export var total_progress_animation_player: AnimationPlayer
@export var total_progress_animation_name: String = "progress"
@export var fraction_progress_animation_players: Array[AnimationPlayer]
@export var fraction_progress_animation_name: String = "progress"

@export_category("Content")
@export var txt: String = ""
@export var value: float = 0

@export var mode: EOperatingMode = EOperatingMode.TEXT
@export var format: EValueFormatType = EValueFormatType.NONE
# String
@export var options: Array[String] = []
@export var min_value: float = 0
@export var max_value: float = 1
@export var cycle_float: bool = false

@export var pick_initial_txt_from_render_label: bool = true

@export_subgroup("Bound Value")
@export var use_bound_value: bool = false
@export var bound_token: String = ""
@export var bound_token_max: String = ""
@export var bound_value_update_rate: float = 15

var timer_gate: GTimeGateHelper = GTimeGateHelper.new(false)

var _progress: float = 0
var _textual_content: String = ""

var _prev_bound_token_value = null
var _prev_bound_token_max_value = null

# Called when the node enters the scene tree for the first time.
func _ready():
	if use_textual_rendering:
		assert(render_label != null, "set Label element to render final value or set `use_textual_rendering` to True")
	
	if pick_initial_txt_from_render_label:
		if render_label != null:
			if render_label.text != "":
				txt = render_label.text
				
				mode = EOperatingMode.TEXT
		
	if use_animated_rendering:
		if total_progress_animation_player != null:
			total_progress_animation_player.play(total_progress_animation_name)
			total_progress_animation_player.pause()	
		for ap in fraction_progress_animation_players:
			ap.play(fraction_progress_animation_name)	
			ap.pause()
			
	update_content()
	pass
	
func set_content(val, _options = null, _min_value = null, _max_value = null):
	if _options is Array:
		options = _options
	if _min_value is float:
		min_value = _min_value
	if _max_value is float:
		max_value = _max_value
		
	alter_content(val)

func alter_content(val):
	if val != null:
		if val is String:
			txt = val
			mode = EOperatingMode.TEXT
			update_content()
		elif val is float or val is int:
			value = val
			mode = EOperatingMode.FLOAT
			_update_float_limits()
			update_content()

func alter_float_limits(_min_value: float, _max_value: float):
	min_value = _min_value
	max_value = _max_value
	_update_float_limits()
	update_content()

func _update_progress():
	_progress = tools.reverse_lerp(value, min_value, max_value)

func _update_textual_content():
	var val

	match mode:
		EOperatingMode.FLOAT:
			val = value
		EOperatingMode.TEXT:
			val = txt
		
	match format:
		EValueFormatType.PERCENTS_FROM_PROGRESS:
			_textual_content = str(round(_progress * 100))
		EValueFormatType.PERCENTS_FROM_PROGRESS_SIGNED:
			_textual_content = str(round(_progress * 100)) + "%"
		EValueFormatType.IX5_FROM_PROGRESS:
			_textual_content = tools.repeat_substring("I", round(_progress * 5))
		EValueFormatType.IX10_FROM_PROGRESS:
			_textual_content = tools.repeat_substring("I", round(_progress * 10))
		EValueFormatType.LX5_FROM_PROGRESS:
			_textual_content = tools.repeat_substring("l", round(_progress * 5))
		EValueFormatType.LX10_FROM_PROGRESS:
			_textual_content = tools.repeat_substring("l", round(_progress * 10))	
		EValueFormatType.YES_NO_FROM_PROGRESS:
			_textual_content = "No" if _progress < 0.5 else "Yes"	
		EValueFormatType.INTEGER:
			_textual_content = str(round(value))
		EValueFormatType.FLOAT2:
			_textual_content = "%2.f" % value
		EValueFormatType.VALUE_SLASH_MAX_INTEGER:
			_textual_content = "%d/%d" % [round(value), round(max_value)]
		EValueFormatType.VALUE_SLASH_MAX_FLOAT:
			_textual_content = "%2.f/%2.f" % [value, max_value]	
		EValueFormatType.NONE:
			_textual_content = str(val)
		EValueFormatType.CUSTOM:
			_textual_content = _format_value(val)
			
	if use_template:
		_textual_content = template.format({
			"content": _textual_content
		})
			
func _format_value(val)->String:
	dev.logd(TAG, "implement custom format function in inherited class")
	return str(value)
	
func _render_content():
	dev.logd(TAG, "implement custom content rendering function in inherited class")
	
func _update_float_limits():
	if cycle_float:
		value = fmod(value, max_value)
	else:
		if max_value >= 0:
			value = clampf(value, min_value, max_value)
	
func update_content():
	_update_progress()
	
	if use_textual_rendering:
		_update_textual_content()
		render_label.text = _textual_content
		
	if use_animated_rendering:
		_update_animated_rendering()
	
func _update_animated_rendering():
	if total_progress_animation_player != null:
		total_progress_animation_player.seek(_progress, true)
		pass
		
	if fraction_progress_animation_players.size() > 0:
		
		var _all_fractions_progress = _progress
		var _max_fraction_progress = 1. /  fraction_progress_animation_players.size()
		
		for anim_player in fraction_progress_animation_players:
			if _all_fractions_progress - _max_fraction_progress > 0:
				anim_player.seek(1, true)
				_all_fractions_progress -= _max_fraction_progress
			else:
				# last fraction
				var _fraction_progress = fmod(_all_fractions_progress, _max_fraction_progress) / _max_fraction_progress
				anim_player.seek(_fraction_progress, true)
				_all_fractions_progress = 0
				
			pass
		
func _process(delta):
	if visible:
		if use_bound_value:
			if timer_gate.check("update_bound_token", 1 / bound_value_update_rate):
				refresh_bound_value()
			
func refresh_bound_value():
	var _val = widgets.get_token(bound_token, value)
	var _max_val = widgets.get_token(bound_token_max, max_value)
	
	if _max_val != _prev_bound_token_max_value:
		alter_float_limits(min_value, _max_val)
		_prev_bound_token_max_value = _max_val
	
	if _val != _prev_bound_token_value:
		alter_content(_val)
		_prev_bound_token_value = _val


