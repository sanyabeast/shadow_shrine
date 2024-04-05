
class_name GProperty
signal on_changed(name: String, old_value: float, new_value: float, increased: bool)

var name: String = ""
var value: float = 0
var target_value: float = 1
var max_value: float = -1
var transition_speed: float = 0

var is_maxed: bool: 
	get:
		return max_value <= 0 or value >= max_value

func _init(_name: String, _value: float, _max_value = null, _transition_speed = null):
	name = _name

	if _max_value != null:
		max_value = _max_value

	if _transition_speed != null:
		transition_speed = _transition_speed

	set_value(_value)

func update(delta: float):
	if transition_speed <= 0:
		value = target_value
	else:
		value = move_toward(value, target_value, transition_speed * delta)

func alter_value(delta: float) -> bool:
	return set_value(target_value + delta)

func set_value(new_value: float) -> bool:
	var old_value: float = target_value
	var changed: bool = false

	if max_value >= 0:
		new_value = clampf(new_value, 0, max_value)

	target_value = new_value

	if new_value != old_value:
		changed = true
		#dev.logd(TAG, "Ability %s target value set to %s" % [name, target_value])
		on_changed.emit(name, old_value, new_value, new_value > old_value)

	update(0)
	return changed
