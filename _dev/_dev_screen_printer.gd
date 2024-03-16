# Author: @sanyabeast
# Date: Jan. 2024

extends Control

class_name GDevScreenPrinter

@onready var menu_container: VBoxContainer = $VBoxContainer

var labels = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	dev.set_screen_printer(self)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func print(topic: String, message: String):
	if topic not in labels:
		var label: Label =  Label.new()
		labels[topic] = label
		label.add_theme_font_size_override("font_size", 12)
		label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		menu_container.add_child(label)
		
	var label: Label = labels[topic]
	
	label.text = message
