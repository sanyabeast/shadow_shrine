extends Resource

class_name RDataIndex 
const TAG: String = "DataIndex"

@export var skills: RDataCatalog
@export var items: RDataCatalog
@export var characters: RDataCatalog

func _to_string():
	return "RDataIndex(name: %s, skills: %s, items: %s, characters: %s)" % [resource_path, skills, items, characters]
