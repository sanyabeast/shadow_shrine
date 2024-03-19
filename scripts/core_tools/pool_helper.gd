# Author: @sanyabeast
# Date: Mar. 2024

# This class provides a helper for managing a pool of nodes in Godot.

class_name GPoolHelper
const TAG: String = "PoolHelper"

var max_size: int = 8
var dictionary_size: int:
	get:
		return _content.keys().size()
		
var _content: Dictionary = {}
var _total_size: int = 0
var overflow_stat: int = 0

# Initialize the pool with a maximum size.
func _init(_max_size: int):
	max_size = _max_size

# Pushes a node into the pool with a given key.
func push(key: String, object: Node) -> bool:
	if not _content.has(key):
		_content[key] = []
		
	if _content[key].size() < max_size:
		_content[key].append(object)
		_total_size += 1
		return true
	else:
		# If the pool is full, free the incoming node.
		object.queue_free()
		overflow_stat += 1
		return false

# Clears all nodes from the pool.
func clear():
	for key in _content.keys():
		var list = _content[key]
		for item in list:
			if item != null:
				item.queue_free()
	_content = {}
	_total_size = 0
	overflow_stat = 0
	dev.logd(TAG, "pool cleared")

# Pulls a node from the pool with a given key.
func pull(key: String) -> Node:
	if not _content.has(key):
		_content[key] = []
	if _content[key].size() > 0:
		_total_size -= 1
		return _content[key].pop_back()
	else:
		return null

# Returns the total size of all nodes in the pool.
func size() -> int:
	return _total_size;
