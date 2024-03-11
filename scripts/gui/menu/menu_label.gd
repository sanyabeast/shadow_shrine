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
	CUSTOM
}

enum EOperatingMode {
	TEXT,
	FLOAT
}

@export_subgroup("Rendering")
@export var use_custom_rendering: bool = false
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

var _progress: float = 0
var _render_text: String = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	if not use_custom_rendering:
		assert(render_label != null, "set Label element to render final value or set `use_custom_rendering` to True")
	
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
		
	if val != null:
		if val is String:
			txt = val
			mode = EOperatingMode.TEXT
			update_content()
		elif val is float:
			value = val
			mode = EOperatingMode.FLOAT
			update_content()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _update_final_value():
	var val

	match mode:
		EOperatingMode.FLOAT:
			_progress = tools.reverse_lerp(value, min_value, max_value)
			val = value
		EOperatingMode.TEXT:
			val = txt
		
	match format:
		EValueFormatType.PERCENTS_FROM_PROGRESS:
			_render_text = str(round(_progress * 100))
		EValueFormatType.PERCENTS_FROM_PROGRESS_SIGNED:
			_render_text = str(round(_progress * 100)) + "%"
		EValueFormatType.IX5_FROM_PROGRESS:
			_render_text = tools.repeat_substring("I", round(_progress * 5))
		EValueFormatType.IX10_FROM_PROGRESS:
			_render_text = tools.repeat_substring("I", round(_progress * 10))
		EValueFormatType.LX5_FROM_PROGRESS:
			_render_text = tools.repeat_substring("l", round(_progress * 5))
		EValueFormatType.LX10_FROM_PROGRESS:
			_render_text = tools.repeat_substring("l", round(_progress * 10))	
		EValueFormatType.NONE:
			_render_text = str(val)
		EValueFormatType.CUSTOM:
			_render_text = _format_value(val)
			
func _format_value(val)->String:
	dev.logd(TAG, "implement custom format function in inherited class")
	return str(value)
	
func _render_content():
	dev.logd(TAG, "implement custom content rendering function in inherited class")
	
func update_content():
	_update_final_value()
	if use_custom_rendering:
		_render_content()
	else:
		render_label.text = _render_text
