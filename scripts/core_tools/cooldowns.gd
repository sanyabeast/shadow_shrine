# Author: @sanyabeast
# Date: Feb. 2024
# This class serves as a cooldown manager for handling various cooldowns in a game.
# It can manage both real-time and game-time based cooldowns.

class_name GCooldowns

# Determines whether the cooldown manager uses game time or real time.
var use_game_time: bool = false
# Dictionary to store cooldown data for different cooldown items.
var _cooldowns_data = {}


# Class representing a cooldown item with an ID, start time, duration, and whether to use game time.
class CooldownItem:
	var id: String
	var started_at: float = 0
	var duration: float = 0
	var use_game_time: bool = false

	# Constructor to initialize the cooldown item with an ID, duration, and time mode.
	func _init(_id: String, _duration: float, _use_game_time: bool):
		id = _id
		use_game_time = _use_game_time
		start(_duration)

	# Start the cooldown with the specified duration.
	func start(_duration: float):
		duration = _duration
		started_at = get_time()

	# Check if the cooldown is ready (progress >= 1).
	func ready() -> bool:
		return progress() >= 1

	# Get the progress of the cooldown as a value between 0 and 1.
	func progress() -> float:
		return clampf((get_time() - started_at) / duration, 0.0, 1.0)

	# Get the remaining time of the cooldown.
	func estimated() -> float:
		return clampf(duration - (get_time() - started_at), 0, duration)

	# Get the current time based on the chosen time mode.
	func get_time() -> float:
		if use_game_time:
			return game.get_time()
		else:
			return tools.get_time()


# Constructor to initialize the cooldown manager with the chosen time mode.
func _init(_use_game_time: bool):
	use_game_time = _use_game_time


# Start a new cooldown or reset the duration of an existing cooldown.
func start(id: String, duration: float):
	if not _cooldowns_data.has(id):
		# Create a new cooldown item if it doesn't exist.
		_cooldowns_data[id] = CooldownItem.new(id, duration, use_game_time)
	else:
		# Reset the duration of an existing cooldown.
		_cooldowns_data[id].start(duration)


# Check if a cooldown with the given ID exists.
func exists(id: String):
	return _cooldowns_data.has(id)


# Stop and remove a cooldown with the given ID.
func stop(id: String):
	if _cooldowns_data.has(id):
		_cooldowns_data.erase(id)


# Get the progress of a cooldown with the given ID.
func progress(id: String) -> float:
	if _cooldowns_data.has(id):
		return _cooldowns_data[id].progress()
	else:
		return 0


# Get the remaining time of a cooldown with the given ID.
func estimated(id: String) -> float:
	if _cooldowns_data.has(id):
		return _cooldowns_data[id].estimated()
	else:
		return 0


# Check if a cooldown with the given ID is ready, optionally triggering on the first call.
func ready(id: String, on_first_call = false) -> bool:
	if _cooldowns_data.has(id):
		return _cooldowns_data[id].ready()
	else:
		return on_first_call


# Reset all cooldowns in the manager.
func reset():
	_cooldowns_data = {}
