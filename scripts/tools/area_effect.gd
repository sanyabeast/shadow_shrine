# Author: @sanyabeast
# Date: Feb. 2024

@icon("res://assets/_dev/_icons/area_1.png")
extends Area3D
class_name GAreaEffect
const TAG: String = "AreaEffect"

@export var max_targets_inside: int = -1
@export var enter_procedures: Array[GProcedure]
@export var exit_procedures: Array[GProcedure]
@export var repeat_procedures: Array[GProcedure]
@export var repeat_procedures_rate: float = 1

@export_subgroup("Activation")
@export var activated_by_player: bool = false
@export var activated_by_enemies: bool = false
@export var activated_by_friends: bool = false
@export var activated_by_static: bool = false
@export var activated_by_projectile: bool = false

var _is_wasted: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	set_collision_layer_value(world.ECollisionBodyType.Character, false)
	set_collision_layer_value(world.ECollisionBodyType.Static, false)
	set_collision_layer_value(world.ECollisionBodyType.Projectile, false)
	set_collision_layer_value(world.ECollisionBodyType.Area, true)
	
	set_collision_mask_value(
		world.ECollisionBodyType.Character, 
		activated_by_player or activated_by_enemies or activated_by_friends
	)
	
	set_collision_mask_value(world.ECollisionBodyType.Static, activated_by_static)
	set_collision_mask_value(world.ECollisionBodyType.Projectile, activated_by_projectile)
	set_collision_mask_value(world.ECollisionBodyType.Area, false)
	
	body_entered.connect(_handle_body_entered)
	body_exited.connect(_handle_body_exited)

func _should_affect(body) -> bool:
	if body is GCharacterController:
		if characters.is_player(body):
			if activated_by_player:
				return true
		else:
			if body.is_friendly:
				return activated_by_friends
			else:
				return activated_by_enemies

func _handle_body_entered(body):
	if _should_affect(body):
		_run_enter_procedures(body)
	
func _handle_body_exited(body):
	if _should_affect(body):
		_run_exit_procedures(body)

func _run_enter_procedures(body):
	for proc in enter_procedures:
		proc.source = self
		proc.target = body
		proc.position = global_position
		proc.direction = global_position.direction_to(body)
		proc.normal = body.global_position.direction_to(self)
		
		proc.start()

func _run_exit_procedures(body):
	for proc in exit_procedures:
		proc.source = self
		proc.target = body
		proc.position = global_position
		proc.direction = global_position.direction_to(body)
		proc.normal = body.global_position.direction_to(self)
		
		proc.start()
