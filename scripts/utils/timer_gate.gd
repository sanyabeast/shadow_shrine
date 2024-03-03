class_name S2TimerGateManager
	
var _timer_gate_data = {}
var use_game_time: bool = false

func _init(_use_game_time: bool):
	use_game_time = _use_game_time

func check(id: String, timeout: float) -> bool:
	var current_time = tools.get_time()
	if not _timer_gate_data.has(id) or current_time - _timer_gate_data[id] >= timeout:
		_timer_gate_data[id] = current_time
		return true
	return false
		
func get_time() -> float:
	if use_game_time:
		return game.get_time()
	else:
		return tools.get_time()
