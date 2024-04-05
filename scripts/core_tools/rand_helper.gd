# Author: @sanyabeast
# Date: Feb. 2024

class_name GRandHelper
var TAG: String = "RandomnessManager"

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var seed: int

func set_seed(_seed: int):
	seed = _seed
	rng.seed = seed

func random_bool() -> bool:
	return rng.randi() % 2 == 0

func random_bool2(ratio: float) -> bool:
	return rng.randf() < ratio

func range(from: float, to: float)->float:
	return rng.randf_range(from, to)

func choice_from_array(arr: Array):
	var index: int =  rng.randi() % arr.size()
	return arr[index]

func choice_from_dict(dict: Dictionary):
	var values = dict.values()
	var index: int = rng.randi() % values.size()
	return values[index]

func choice_key_from_dict(dict: Dictionary):
	var keys = dict.keys()
	var index: int = rng.randi() % keys.size()
	return keys[index]

func randi()->int:
	return rng.randi()
	
func randf()->int:
	return rng.randf()
