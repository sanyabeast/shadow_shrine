# Author: @sanyabeast
# Date: Feb. 2024

extends Resource
class_name RGameLevelConfig

@export var title: String = ""

@export_subgroup("Rooms")
@export var start_rooms: Array[PackedScene] = []
@export var special_rooms: Array[PackedScene] = []
@export var end_rooms: Array[PackedScene] = []
@export var rooms: Array[PackedScene] = []

@export_subgroup("Ambient Sound")
@export var explore_playlist: Array[AudioStream] = []
@export var battle_playlist: Array[AudioStream] = []
