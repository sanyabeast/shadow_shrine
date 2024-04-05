# Author: @sanyabeast
# Date: Feb. 2024

@icon("res://assets/_dev/_icons/pencil3.png")
extends Node
class_name GThesaurusEntry
var TAG:= "ThesaurusEntry"

@export var title: String = ""
@export var summary: String = ""
@export var icon: Texture
@export var banner: Texture
@export var rarity: float = 0
@export var main_scene: PackedScene
@export var demo_scene: PackedScene
@export var tags: Array[String]
@export var props: Dictionary = {}


var id: String:
	get:
		return name

func _to_string():
	return "ThesaurusEntry(id: %s, title: %s, rarity: %s)" % [name, title, rarity]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
