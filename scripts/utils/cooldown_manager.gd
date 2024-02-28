class_name S2CooldownManager

var use_game_time: bool = false
var _cooldowns_data = {}

class CooldownItem:
	var id: String
	var started_at: float = 0
	var duration: float = 0
	var use_game_time: bool = false
	
	func _init(_id: String, _duration: float, _use_game_time: bool):
		id = _id
		use_game_time = _use_game_time
		start(_duration)
	func start(_duration: float):
		duration = _duration
		started_at = get_time()
	func ready()->bool:
		return progress() >= 1
	func progress()->float:
		return clampf((get_time() - started_at) / duration, 0.0, 1.0)
	func estimated()->float:
		return clampf(duration - (get_time() - started_at), 0, duration)

	func get_time() -> float:
		if use_game_time:
			return game.get_time()
		else:
			return tools.get_time()

func _init(_use_game_time: bool):
	use_game_time = _use_game_time

func start(id: String, duration: float):
	if not _cooldowns_data.has(id):
		_cooldowns_data[id] = CooldownItem.new(id, duration, use_game_time)
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
