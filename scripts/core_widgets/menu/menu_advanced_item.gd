# Author: @sanyabeast
# Date: Feb. 2024

extends GMenuItem
class_name GMenuItemAdvanced

enum EValueFormatType {
	None,
	PercentageFrom0_1,
	ConsoleTypeFrom_0_1,
}

@export_subgroup("Title")
@export var title: String = ""
@export var title_element: Label

@export_subgroup("Value")
@export var value_element: GWidgetLabel

var _prev_value: String = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	if title_element != null and title != "":
		title_element.text = title
	pass

func _after_option_updated():
	if value_element != null:
		value_element.set_content(get_value(), options, min_value, max_value)
