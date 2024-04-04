# Author: @sanyabeast
# Date: Apr. 2024

extends GMenuController
class_name GMenuGenerative

enum EItemGenerationMode {
	Duplicate,
	Instantiate
}

@export_subgroup("# Menu Generative")
@export var items_container: Control

@export_subgroup("# Menu Generative ~ Item")
@export var item_to_duplicate: GMenuItem
@export var item_to_instantiate: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
