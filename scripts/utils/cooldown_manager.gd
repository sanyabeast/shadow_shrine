class_name S2CooldownManager

var _cooldowns_data = {}

class CooldownItem:
	var id: String
	var started_at: float = 0
	var duration: float = 0
	func _init(_id: String, _duration: float):
		id = _id
		start(_duration)
	func start(_duration: float):
		duration = _duration
		started_at = tools.get_time()
	func ready()->bool:
		return progress() >= 1
	func progress()->float:
		return clampf((tools.get_time() - started_at) / duration, 0.0, 1.0)
	func estimated()->float:
		return clampf(duration - (tools.get_time() - started_at), 0, duration)

func start(id: String, duration: float):
	if not _cooldowns_data.has(id):
		_cooldowns_data[id] = CooldownItem.new(id, duration)
	else:
		_cooldowns_data[id].start(duration)
func exists(id: String):
	return _cooldowns_data.has(id)
	
func stop(id: String):
	if _cooldowns_data.has(id):
		_cooldowns_data.erase(id)
		
func progress(id: String)->float:
	if _cooldowns_data.has(id):
		return _cooldowns_data[id].progress()
	else:
		return 0
		
func estimated(id: String)->float:
	if _cooldowns_data.has(id):
		return _cooldowns_data[id].estimated()
	else:
		return 0
		
func ready(id: String, on_first_call = false)->bool:
	if _cooldowns_data.has(id):
		return _cooldowns_data[id].ready()
	else:
		return on_first_call
		
func reset():
	_cooldowns_data = {}
