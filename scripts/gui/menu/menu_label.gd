# Author: @sanyabeast
# Date: Mar. 2024

extends Control
class_name S2MenuLabel
const TAG: String = "MenuLabel"

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
	CUSTOM
}

enum EOperatingMode {
	TEXT,
	FLOAT
}

@export_category("Rendering")
@export var use_textual_rendering: bool = true
@export var render_label: Label

@export_category("Content")
@export var txt: String = ""
@export var value: float = 0

@export var mode: EOperatingMode = EOperatingMode.TEXT
@export var format: EValueFormatType = EValueFormatType.NONE
# String
@export var options: Array[String] = []
@export var min_value: float = 0
@export var max_value: float = 1

@export var pick_initial_txt_from_render_label: bool = true

@export_subgroup("Bound Value")
@export var use_bound_value: bool = false
@export var bound_token: String = ""
@export var bound_value_update_rate: float = 4
@export var token_for_min: String = ""
@export var token_for_max: String = ""

var timer_gate: S2TimerGateManager = S2TimerGateManager.new(false)

var _progress: float = 0
var _textual_content: String = ""

var _prev_bound_token_value = null
var _prev_bound_token_value_min = null
var _prev_bound_token_value_max = null

# Called when the node enters the scene tree for the first time.
func _ready():
	if use_textual_rendering:
		assert(render_label != null, "set Label element to render final value or set `use_textual_rendering` to True")
	
	if pick_initial_txt_from_render_label:
		if render_label != null:
			if render_label.text != "":
				txt = render_label.text
				mode = EOperatingMode.TEXT
				
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
		elif val is float:
			value = val
			mode = EOperatingMode.FLOAT
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
			_textual_content = "%d.2" % value
		EValueFormatType.NONE:
			_textual_content = str(val)
		EValueFormatType.CUSTOM:
			_textual_content = _format_value(val)
			
func _format_value(val)->String:
	dev.logd(TAG, "implement custom format function in inherited class")
	return str(value)
	
func _render_content():
	dev.logd(TAG, "implement custom content rendering function in inherited class")
	
func update_content():
	_update_progress()
	
	if use_textual_rendering:
		_update_textual_content()
		render_label.text = _textual_content
		
func _process(delta):
	if visible:
		if use_bound_value:
			if timer_gate.check("update_bound_token", 1 / bound_value_update_rate):
				refresh_bound_value()
			
func refresh_bound_value():
	if gui.tokens[bound_token] != _prev_bound_token_value:
		alter_content(gui.tokens[bound_token])
		_prev_bound_token_value = gui.tokens[bound_token]
