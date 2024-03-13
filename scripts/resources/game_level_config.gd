# Author: @sanyabeast
# Date: Feb. 2024

extends Resource
class_name RGameLevelConfig

@export var rooms: Array[PackedScene] = []

@export_subgroup("Ambient Sound")
@export var explore_playlist: Array[AudioStream] = []
@export var battle_playlist: Array[AudioStream] = []
