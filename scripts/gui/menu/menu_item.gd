extends Control

class_name S2MenuItem
const TAG: String = "MenuItem"

@export var title: String = "Menu Item"
@export var value: float = 0
@export var min_value: float = 0
@export var max_value: float = 1
@export var step: float = 1
@export var options: Array = []
@export var option_index: int = 0
@export var anim_player: AnimationPlayer

var is_active: bool = false
var is_hovered: bool = false

var _options_mode: bool = false


signal on_active_change(item: S2MenuItem, is_active: bool)
signal on_hover_change(item: S2MenuItem, is_hovered: bool)
signal on_submit(item: S2MainMenu)

# Called when the node enters the scene tree for the first time.
func _ready():
	_options_mode = options.size() > 0
	pass # Replace with function body.

func _to_string():
	return "MenuItem(name: %s, title: %s, value: %s)" % [name, title, value]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_float() -> float:
	return value
	
func get_bool() -> bool:
	return value > 0.5

func next_option():
	if _options_mode:
		option_index = (option_index + 1) % options.size()
	else:
		value = clampf(value + step, min_value, max_value)
	
func prev_option():
	if _options_mode:
		option_index = (option_index - 1) % options.size()
	else:
		value = clampf(value - step, min_value, max_value)
	
func toggle():
	value = 0 if get_bool() else 1 

func set_active(_is_active: bool):
	dev.logd(TAG, "active change for %s, active: %s" % [self, _is_active])
	is_active = _is_active
	
	if anim_player != null:
		if is_active:
			anim_player.play("select")
		else:
			anim_player.play("default")
	
	on_active_change.emit(self, is_active)
	
func set_hover(_is_hovered: bool):
	dev.logd(TAG, "hover change for %s, hover: %s" % [self, _is_hovered])
	is_hovered = _is_hovered
	
	if anim_player != null:
		if is_hovered:
			anim_player.play("hover")
		else:
			anim_player.play("default")
	
	on_hover_change.emit(self, is_hovered)

func submit():
	dev.logd(TAG, "submitted %s" % self)
	on_submit.emit(self)
	
	if anim_player:
		anim_player.play("submit")
