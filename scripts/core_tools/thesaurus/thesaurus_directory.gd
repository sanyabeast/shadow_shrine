# Author: @sanyabeast
# Date: Feb. 2024

@icon("res://assets/_dev/_icons/bookmark_a.png")
extends Node
class_name GThesaurusDirectory
var TAG:= "ThesaurusDirectory"

## recommendation: use lowercase plural 
@export var category: String

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(category != "", "Thesaurus category sould be NON-empty string - category id")

