extends Resource
class_name RMazeConfig

## Defines size of maze grid
@export_range(2, 8, 1) var size: int = 3
@export_range(0, 1, 0.01) var sparseness: float = 0.5
@export_range(0, 1, 0.01) var dead_ends: float = 0.5
@export_range(0, 1, 0.01) var shortcuts: float = 0.5

func _to_string():
	return "MazeConfig(size: %s, sparseness: %s, dead_ends: %s, shortcuts: %s)" % [size, sparseness, dead_ends, shortcuts]
