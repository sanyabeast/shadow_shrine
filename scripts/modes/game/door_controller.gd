# Author: @sanyabeast
# Date: Feb. 2024

# This script defines a door controller that manages the opening and closing of a door in a 3D game.

extends GAreaEffect
class_name GDoorController
#var TAG: String = "DoorController"

@export_subgroup("# Door Controller")
@export var surface_material_helper: GSurfaceMaterialHelper
@onready var player_spawn: Node3D = $PlayerSpawn
@onready var blocker: StaticBody3D = $Blocker

var direction: world.EDirection = world.EDirection.North

func _ready():
	direction = world.get_node_direction(self)
	super._ready()

func _process(delta):
	super._process(delta)
	
	if visible:
		if surface_material_helper != null:
			if enabled and surface_material_helper.current_state_id == "default":
				surface_material_helper.enter_state("focus")
			
			if not enabled and surface_material_helper.current_state_id == "focus":
				surface_material_helper.enter_state("default")

func enable(skip_fx: bool = false):
	blocker.process_mode = Node.PROCESS_MODE_DISABLED
	super.enable(skip_fx)
	
func disable(skip_fx: bool = false):
	blocker.process_mode = Node.PROCESS_MODE_ALWAYS
	super.disable(skip_fx)
