# Author: @sanyabeast
# Date: Feb. 2024

extends S2MenuItem

class_name S2MenuAdvancedItem

enum EValueFormatType {
	None,
	PercentageFrom0_1,
	ConsoleTypeFrom_0_1,
}

@export_subgroup("Title")
@export var title: String = ""
@export var title_element: Label

@export_subgroup("Value")
@export var value_element: S2MenuLabel

var _prev_value: String = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	if title_element != null and title != "":
		title_element.text = title
	pass


func _generate_console_type(value: float) -> String:
	var r = ""
	var max_count: int = 5
	var count: int = round(value * max_count)
	for i in max_count:
		if i > count:
			r += ""
		else:
			r += "#"
	return r

func _after_option_updated():
	if value_element != null:
		value_element.set_content(value)
