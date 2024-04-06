# Author: @sanyabeast
# Date: Apr. 2024

@icon("res://assets/_dev/_icons/dotto-emoji-main-svg/Dotto Emoji116.svg")
extends Node
class_name GTalent
var TAG:= "Talent"

@export_subgroup("# Talent")
@export var id: String = ""
@export var enabled: bool = true

var target: Node
var active: bool = false

func _ready():
	assert(id != "", "GTalent id should be NON-empty string. found at %s" % self)

func initialize(_target: Node):
	target = _target
	_initialize()
	
func _initialize():
	dev.logd(TAG, "implement GTalent initialization function. found at %s" % self)
	pass

func start_use():
	active = true
	_on_start_use()
	
func stop_use():
	active = false
	_on_stop_use()

func _on_start_use():
	dev.logd(TAG, "implement GTalent _on_start_use function. found at %" % self)
	pass
	
func _on_stop_use():
	dev.logd(TAG, "implement GTalent _on_stop_use function. found at %" % self)
	pass

func update(delta):
	if enabled:
		_update_state(delta)

func update_physics(delta):
	if enabled:
		_update_physics(delta)
	
func _update_state(delta):
	pass

func _update_physics(delta):
	pass
