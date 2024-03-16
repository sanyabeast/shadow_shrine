# Author: @sanyabeast
# Date: Feb. 2024

extends Resource
class_name RDataCatalog 
const TAG: String = "DataCatalog"

@export var items: Array[RDataCard] = []

func _init():
	tools.logd(TAG, "data catalog inited, items count: %s" % items.size())

func _to_string():
	return "RDataCatalog(name: %s, items: %s)" % [resource_path, items.size()]
