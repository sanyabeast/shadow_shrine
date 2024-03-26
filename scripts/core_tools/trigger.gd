# Author: @sanyabeast
# Date: Mar. 2024


@icon("res://assets/_dev/_icons/35t.png")
extends GProcedure
class_name GTriggerProcedure

@export_placeholder("placeholder id") var id:= ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _start():
	if game.mode != null:
		dev.logd("TriggerProcedure", "triggering %s" % id)
		game.mode.trigger(id)
	pass
