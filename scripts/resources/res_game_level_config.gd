# Author: @sanyabeast
# Date: Feb. 2024

extends Resource
class_name RGameLevelConfig

@export_subgroup("♥ GameLevelConfig")
@export var title: String = ""

@export_subgroup("♥ GameLevelConfig ~ Rooms")
@export var start_rooms: Array[PackedScene] = []
@export var special_rooms: Array[PackedScene] = []
@export var end_rooms: Array[PackedScene] = []
@export var rooms: Array[PackedScene] = []

@export_subgroup("♥ GameLevelConfig ~ Ambient Sound")
@export var explore_playlist: Array[AudioStream] = []
@export var battle_playlist: Array[AudioStream] = []
