extends Node

class_name PlayerManager

var current: S2Character

func set_active(character: S2Character):
	print("player manager: active character: %s" % character)
	current = character

# Called when the node enters the scene tree for the first time.
func _ready():
	print("player manager: ready...")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
