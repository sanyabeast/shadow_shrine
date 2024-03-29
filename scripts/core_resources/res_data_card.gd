# Author: @sanyabeast
# Date: Feb. 2024

extends Resource
class_name RDataCard

@export_subgroup("♥ DataCard")
@export var name: String = ""
@export var title: String = ""
@export var summary: String = ""
@export var icon: Image
@export var banner: Image

@export_subgroup("♥ DataCard ~ Extras")
@export var data: Dictionary = {}

@export var demo_scene: PackedScene
@export var main_scene: PackedScene

