extends Node3D

class_name S2GameSceneController

@onready var environment_node: Node3D = $Environment
@onready var architecture_node: Node3D = $Architecture
@onready var characters_node: Node3D = $Characters
@onready var collectibles_node: Node3D = $Collectibles

# Called when the node enters the scene tree for the first time.
func _ready():
	
	assert(environment_node != null, "$Environment node not found")
	assert(architecture_node != null, "$Architecture node not found")
	assert(characters_node != null, "$Characters node not found")
	assert(collectibles_node != null, "$Collectibles node not found")
	
	print("game scene controller: ready...")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
