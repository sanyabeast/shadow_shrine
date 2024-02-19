class_name S2TimerGateManager
	
var _timer_gate_data = {}

func check(id: String, timeout: float) -> bool:
	var current_time = tools.get_time()
	if not _timer_gate_data.has(id) or current_time - _timer_gate_data[id] >= timeout:
		_timer_gate_data[id] = current_time
		return true
	return false
		

