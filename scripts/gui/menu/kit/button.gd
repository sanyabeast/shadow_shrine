# Author: @sanyabeast
# Date: Feb. 2024

extends S2MenuItem

class_name S2MenuItemButton

@export var title_element: Label

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	title_element.text = title
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
