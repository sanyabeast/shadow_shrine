extends Resource

class_name RSurfaceStates

@export var list: Array[RSurfaceState] = []

func to_dict() -> Dictionary:
	var dict = {}
	for item in list:
		dict[item.id] = item
	return dict
