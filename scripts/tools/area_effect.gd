# Author: @sanyabeast
# Date: Feb. 2024

@icon("res://assets/_dev/_icons/area_1.png")
extends Area3D
class_name GAreaEffect
const TAG: String = "AreaEffect"

@export_subgroup("# Area Effect")
@export var enabled: bool = true
@export var max_targets_inside: int = -1
@export var enter_procedures: Array[GProcedure]
@export var exit_procedures: Array[GProcedure]
@export var repeat_procedures: Array[GProcedure]
@export var repeat_procedures_rate: float = 1

@export_subgroup("# Area Effect ~ Activation")
@export var activated_by_player: bool = false
@export var activated_by_enemies: bool = false
@export var activated_by_friends: bool = false
@export var activated_by_static: bool = false
@export var activated_by_projectile: bool = false

@export_subgroup("# Area Effect ~ FX")
@export var enter_fx: RFXConfig
@export var exit_fx: RFXConfig
@export var repeat_fx: RFXConfig
@export var enable_fx: RFXConfig
@export var disable_fx: RFXConfig

@export_subgroup("# Area Effect ~ Animations")
@export var anim_player: AnimationPlayer

@export_subgroup("# Area Effect ~ Misc")
@export var gizmo: GGizmo

var _is_wasted: bool = false
var bodies_inside: Dictionary = {}
var _time_gate:= GTimeGateHelper.new(true)
var _bodies_inside_count: int = 0

func _to_string():
	return "AreaEffect(name: %s, enabled: %s, bodies_inside: %s)" % [name, enabled, _bodies_inside_count]

# Called when the node enters the scene tree for the first time.
func _ready():
	var coll_mask: Array[world.ECollisionBodyType] = []
	
	if activated_by_player or activated_by_enemies or activated_by_friends:
		coll_mask.append(world.ECollisionBodyType.Character)
	if activated_by_static:
		coll_mask.append(world.ECollisionBodyType.Static)
	if activated_by_projectile:
		coll_mask.append(world.ECollisionBodyType.Projectile)
	
	world.set_collision(self, world.ECollisionBodyType.Area, coll_mask)
	
	body_entered.connect(_handle_body_entered)
	body_exited.connect(_handle_body_exited)
	
	# Initialize the door state based on the 'enabled' flag.
	if enabled:
		enable(true)
	else:
		disable(true)
	
	name = "area_effect"

func _process(delta):
	if enabled and repeat_procedures.size() and _time_gate.check("repeat", 1. / repeat_procedures_rate):
		if bodies_inside.keys().size() > 0:
			if exit_fx:
					world.spawn_fx(exit_fx, global_position, null, global_rotation_degrees)
			for key in bodies_inside.keys():
				_run_procedures(bodies_inside[key], repeat_procedures)
	
	if tools.IS_DEBUG:
		dev.set_label(self, { "self": to_string() } )
		
		if gizmo != null:
			if enabled:
				if _bodies_inside_count > 0:
					gizmo.state = "active"
				else:
					gizmo.state = "default"
			else:
				gizmo.state = "disabled"

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
	return false

func _handle_body_entered(body: Node3D):
	if _should_affect(body):
			bodies_inside[body.get_instance_id()] = body
			_bodies_inside_count = bodies_inside.keys().size()
			if enabled:
				if enter_fx:
					world.spawn_fx(enter_fx, global_position, null, global_rotation_degrees)
				
				_run_procedures(body, enter_procedures)
	
func _handle_body_exited(body):
	if _should_affect(body):
		bodies_inside.erase(body.get_instance_id())
		_bodies_inside_count = bodies_inside.keys().size()
		if enabled:
			if exit_fx:
				world.spawn_fx(exit_fx, global_position, null, global_rotation_degrees)
			
			_run_procedures(body, exit_procedures)

func _run_procedures(body: Node3D, procedures: Array[GProcedure]):
	for proc in procedures:
		proc.source = self
		proc.target = body
		proc.position = global_position
		proc.direction = global_position.direction_to(body.global_position)
		proc.normal = body.global_position.direction_to(global_position)
		
		proc.start()

func enable(skip_fx: bool = false):
	skip_fx = skip_fx or not visible
	
	if not skip_fx and enable_fx:
		world.spawn_fx(enable_fx, global_position, null, global_rotation_degrees)
		
	if anim_player != null and anim_player.has_animation("Open"):
		anim_player.play("Open")
		if skip_fx:
			anim_player.seek(anim_player.current_animation_length)
		
	enabled = true
	
func disable(skip_fx: bool = false):
	skip_fx = skip_fx or not visible
	
	if not skip_fx and disable_fx:
		world.spawn_fx(disable_fx, global_position, null, global_rotation_degrees)
		
	if anim_player != null and anim_player.has_animation("Close"):
		anim_player.play("Close")
		if skip_fx:
			anim_player.seek(anim_player.current_animation_length)	
		
	enabled = false
