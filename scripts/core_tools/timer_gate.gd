# Author: @sanyabeast
# Date: Feb. 2024

# This script defines a timer gate manager for handling time-based checks.

class_name GTimeGateHelper

# Dictionary to store the last recorded time for each timer gate.
var _timer_gate_data = {}
# Flag to determine whether to use game time or real time.
var use_game_time: bool = false

# Constructor to initialize the timer gate manager with the chosen time mode.
func _init(_use_game_time: bool):
	use_game_time = _use_game_time

# Method to check if a specified timer gate has expired based on the given timeout.
# Returns true if the timer gate has expired, false otherwise.
func check(id: String, timeout: float) -> bool:
	# Get the current time.
	var current_time = tools.get_time()
	
	# Check if the timer gate doesn't exist or has exceeded the timeout.
	if not _timer_gate_data.has(id) or current_time - _timer_gate_data[id] >= timeout:
		# Update the timer gate with the current time and return true.
		_timer_gate_data[id] = current_time
		return true
	# If the timer gate is still within the timeout, return false.
	return false

# Method to get the current time based on the chosen time mode.
func get_time() -> float:
	if use_game_time:
		return game.get_time()
	else:
		return tools.get_time()
