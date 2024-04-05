

@icon("res://assets/_dev/_icons/gem_a.png")
extends GAreaEffect
class_name GPickup

@export_subgroup("# Pickup")
@export var procedures: Array[GProcedure] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	enter_procedures = procedures
	activated_by_player = true
	
	super._ready()
	name = "pickup"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)
	pass
