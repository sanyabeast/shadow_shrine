# Author: @sanyabeast
# Date: Feb. 2024

class_name S2RandomnessManager
const TAG: String = "RandomNessManager"

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var seed: int

func set_seed(_seed: int):
	seed = _seed
	rng.seed = seed

func random_bool() -> bool:
	return rng.randi() % 2 == 0

func range(from: float, to: float)->float:
	return rng.randf_range(from, to)

func choice_from_array(arr: Array) -> Variant:
	var index: int =  rng.randi() % arr.size()
	return arr[index]

func choice_from_dict(dict: Dictionary) -> Variant:
	var keys = dict.keys()
	var index: int = rng.randi() % keys.size()
	return dict[keys[index]]

func randi()->int:
	return rng.randi()
	
func randf()->int:
	return rng.randf()
