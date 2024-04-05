

@icon("res://assets/_dev/_icons/gem_a.png")
extends GAreaEffect
class_name GPickup

@export_subgroup("# Pickup")
@export var id: String = ""
## Pickup sets this procedures as `enter_procedures`
@export var procedures: Array[GProcedure] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(id != "", "GPickup requires `id` as non-empty string")
	enter_procedures = procedures
	activated_by_player = true
	activated_by_enemies = false
	activated_by_friends = false
	activated_by_projectile = false
	activated_by_static = false
	max_targets_inside = 1
	max_activations = 1
	one_success_activation = true
	all_success_activation = false
	
	super._ready()
	name = "pickup"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)
	pass
