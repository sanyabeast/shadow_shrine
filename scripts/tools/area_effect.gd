# Author: @sanyabeast
# Date: Feb. 2024

@icon("res://assets/_dev/_icons/area_1.png")
extends Area3D
class_name GAreaEffect
const TAG: String = "AreaEffect"

@export var max_affected_targets: int = -1
@export var enter_procedures: Array[GProcedure]
@export var exit_procedures: Array[GProcedure]

@export_subgroup("Targeting")
@export var affect_player: bool = false
@export var affect_enemies: bool = false
@export var affect_friends: bool = false

@export var affect_static: bool = false

var _affected_targets: int = 0
var _is_wasted: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_handle_body_entered)
	body_exited.connect(_handle_body_exited)
	pass # Replace with function body.

func _should_affect(body) -> bool:
	if max_affected_targets >= 0 and _affected_targets >= max_affected_targets:
		_is_wasted = true
		return false
	else:
		if body is GCharacterController:
			if characters.is_player(body):
				if affect_player:
					return true
			else:
				if body.is_friendly:
					return affect_friends
				else:
					return affect_enemies
		pass
	return false

func _handle_body_entered(body):
	if not _is_wasted:
		if _should_affect(body):
			_run_enter_procedures(body)
			_affected_targets += 1
			
	if max_affected_targets >= 0 and _affected_targets >= max_affected_targets:
		_is_wasted = true
	#if body
	#if not _is_wasted:
		#if body is GCharacterController:
			#if keeper and body != keeper:
				#dev.logd(TAG, 'projectile hit character %s' % body)
				#_handle_hit(body)
		#else:
			#dev.logd(TAG, 'projectile hit something %s' % body)
			#_handle_block()
	
func _handle_body_exited(body):
	if not _is_wasted:
		if _should_affect(body):
			_run_exit_procedures(body)

func _run_enter_procedures(body):
	pass

func _run_exit_procedures(body):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
