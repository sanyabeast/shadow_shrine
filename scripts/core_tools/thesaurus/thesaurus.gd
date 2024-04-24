## This script defines a thesaurus class for managing various entries categorized into different categories.

# Author: @sanyabeast
# Date: Feb. 2024

@icon("res://assets/_dev/_icons/book_04g.png")
extends Node
class_name GThesaurus
var TAG:= "Thesaurus"

# The unique identifier for the thesaurus.
@export var id: String = ""
# Dictionary containing all entries categorized by String.
var content: Dictionary = {}

# Random number generator instance.
var random:= GRandHelper.new()

## Converts the GThesaurus object to a string representation.
func _to_string():
	return "Thesaurus(id: %s)" % [id]

## Called when the node enters the scene tree for the first time.
func _ready():
	assert(id.length() > 0, "Thesaurus `id` must be not empty string. found at %" % [name])
	set_seed(game.seed)
	game.on_seed_changed.connect(_handle_seed_changed)
	_init_content()
	dev.logd(TAG, "inited: %s" % self)

## Initializes the content of the thesaurus.
func _init_content():
	_traverse(self)

## Parses entries within a node.
func _parse_entries(category: String, list: Node):
	for i in list.get_child_count():
		if list.get_child(i) is GThesaurusEntry:
			add_entry(category, list.get_child(i))

## Adds an entry to the thesaurus under specified category.
func add_entry(category: String, entry: GThesaurusEntry):
	var entries = get_entries(category) 
	dev.logd(TAG, "adding entry `%s` to category %s" % [entry.id, category])
	if entries.has(entry.id):
		dev.logd(TAG, "entry with id `%s` already exists in category `%s`. overwriting..." % [entry.id, category])
	entries[entry.id] = entry

func get_entry(category: String, id: String) -> GThesaurusEntry:
	var entries = get_entries(category)
	return entries[id]

## Retrieves entries for a specific category.
func get_entries(category: String) -> Dictionary:
	if not content.has(category):
		dev.logd(TAG, "dictionary for category `%s` does not exist. creating..." % category)
		content[category] = {}
	return content[category] 

## Traverses through nodes to parse entries.
func _traverse(node):
	if node is GThesaurusDirectory:
		_parse_entries(node.category, node)
				
	for child in node.get_children():
		_traverse(child)

## Retrieves a single item from a list based on rarity and specified criteria.
func get_one_item_from_list_by_rarity(category: String, ids: Array[String], curve: float = 1) -> GThesaurusEntry:
	dev.logd(TAG, "get_one_item_from_list_by_rarity(%s, %s)" % [category, ids])
	var rarity_map: Dictionary = _get_relative_rarity_map(category, curve, ids)
	dev.logd(TAG, 'built rarity map is: %s' % rarity_map)
	
	var result: GThesaurusEntry = null
	
	if rarity_map.keys().size() > 0:
		while result == null:
			var random_element: GThesaurusEntry = random.choice_key_from_dict(rarity_map)
			if random.random_bool2(1. - rarity_map[random_element]):
				result = random_element
				break
	else:
		dev.logd(TAG, "failed to get_one_item_from_list_by_rarity, no entries mathes filters: %s, %s" %  [category, ids])
	
	dev.logd(TAG, "picked item is %s" % result)
	return result

## Filters entries based on specified criteria.
func filter_entries(category: String, includes: Array[String] = [], excludes: Array[String] = []) -> Array[GThesaurusEntry]:
	var filtered_entries: Array[GThesaurusEntry] = []
	var cat_entries = get_entries(category)
	
	for id in cat_entries.keys():
		var entry = cat_entries[id]
		if includes.size() == 0 and excludes.size() == 0:
			filtered_entries.append(entry)
		else:
			if includes.size() > 0 and includes.find(entry.id) > -1:
				filtered_entries.append(entry)
				continue
			
			if excludes.size() > 0 and excludes.find(entry.id) < 0:
				filtered_entries.append(entry)
	
	return filtered_entries

## Generates a rarity map based on rarity of entries.
func _get_relative_rarity_map(category: String, curve: float = 1, includes: Array[String] = [], excludes: Array[String] = []) -> Dictionary:
	var filtered_entries: Array[GThesaurusEntry] = filter_entries(category, includes, excludes)
	var rarity_map: Dictionary = {}
	var rarity_sum: float = 0
	
	for item in filtered_entries:
		rarity_sum += item.rarity
		
	for item in filtered_entries:
		var rel_rarity = item.rarity / rarity_sum
		rel_rarity = 1. - pow(1. - rel_rarity, 1. / curve)
		rarity_map[item] = rel_rarity
		
	return rarity_map
			
## Handles the change of seed.
func _handle_seed_changed(seed: int):
	set_seed(seed)

## Sets the seed for the random number generator.
func set_seed(seed: int):
	random.set_seed(seed)