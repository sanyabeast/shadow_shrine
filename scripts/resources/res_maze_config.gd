extends Resource
class_name RMazeConfig

@export var size: int = 3
@export var sparseness: float = 0.5
@export var dead_ends: float = 0.5
@export var shortcuts: float = 0.5

func _to_string():
	return "MazeConfig(size: %s, sparseness: %s, dead_ends: %s, shortcuts: %s)" % [size, sparseness, dead_ends, shortcuts]
