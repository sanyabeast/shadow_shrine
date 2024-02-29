extends Node

class_name S2SkillSystem
const TAG: String = "SkillSystem"

class S2Skill:
	var name: String = ""
	var value: float = 1
	var max_value: float = 0
	
	func _init(_name: String, _value: float = 1, _max_value: float = 0):
		name = _name
		value = _value
		max_value = _max_value
	pass
	
class S2Effect:
	pass

var skills: Dictionary = {}
var effects: Array[S2Effect] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _to_string():
	var skills_names: Array[String] = []
	for key in skills:
		skills_names.append(key)
		
	return "SkillSystem(skills: %s)" % ", ".join(skills_names)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func add_skill(name: String, value: float = 1, max_value: float = 0):
	skills[name] = S2Skill.new(name, value, max_value)
		
