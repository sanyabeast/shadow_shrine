# Author: @sanyabeast
# Date: Feb. 2024

extends Area3D

class_name GProjectileController
const TAG: String = "ProjectileController"

@export var config: RProjectileConfig
@export var hit_procedures: Array[GProcedure] = []
@export var ray: RayCast3D

@export_subgroup("Projectile FX")
@export var launch_fx: RFXConfig
@export var block_fx: RFXConfig
@export var hit_fx: RFXConfig
@export var waste_fx: RFXConfig

@export_subgroup("Body")
@export var body: Node3D
@export var hide_body_on_block: bool = true
@export var hide_body_on_hit: bool = true

@export_subgroup("Misc")
@export var auto_launch: bool = false
@export var direction: Vector3 = Vector3.FORWARD
@export var keeper: Node3D

@export_subgroup("FX Anchors")
@export var launch_fx_anchor: Node3D
@export var block_fx_anchor: Node3D
@export var hit_fx_anchor: Node3D

var cooldown: GCooldowns = GCooldowns.new(true)
var current_velocity: float = 0

var _is_launched: bool = false
var _hits_and_blocks_count: int = 0
var _is_wasted: bool = false

var _collision_normal: Vector3 = Vector3.ZERO
var _collision_point: Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_handle_body_entered)
	body_exited.connect(_handle_body_exited)
	
	if ray != null:
		ray.add_exception(self)
		ray.add_exception(keeper)
	
	if auto_launch:
		launch()
	
	pass # Replace with function body.

func launch():
	look_at(global_position + direction)
	cooldown.start("max_lifetime", config.max_lifetime)
	current_velocity = config.start_velocity
	_is_launched = true
	
	#if launch_audio_stream:
		#launch_audio_stream.pitch_scale = randf_range(launch_audio_pitch_min, launch_audio_pitch_max)
		#launch_audio_stream.play()
	
	if launch_fx:
		world.spawn_fx(launch_fx, global_position, launch_fx_anchor if launch_fx_anchor else self)

func _handle_body_entered(_hit_body):
	if not _is_wasted:
		if _hit_body is GCharacterController:
			if keeper and _hit_body != keeper:
				dev.logd(TAG, 'projectile hit character %s' % _hit_body)
				_handle_hit(_hit_body)
		else:
			dev.logd(TAG, 'projectile hit something %s' % _hit_body)
			_handle_block(_hit_body)
	
func _handle_body_exited(_hit_body):
	pass

func _handle_block(_hit_body):
	_update_ray_collision()
	
	if hide_body_on_block and body:
		body.hide()
		
	if block_fx:
		world.spawn_fx(block_fx, global_position)	
		
	_hits_and_blocks_count += 1	
	
	_reflect()
	_deviate(config.block_direction_deviation)
		
	if config.max_hits_and_blocks > 0 and _hits_and_blocks_count >= config.max_hits_and_blocks:
		_is_wasted = true
	
	if _is_wasted:
		
		if waste_fx:
			world.spawn_fx(waste_fx, _collision_point, hit_fx_anchor if hit_fx_anchor else self)
			
		_dispose()
	
func _handle_hit(_hit_body: GCharacterController):
	_update_ray_collision()
	
	for proc in hit_procedures:
		proc.source = keeper
		proc.target = _hit_body
		proc.position = _collision_point
		proc.direction = direction
		proc.normal = _collision_normal
		
		proc.start()
	
	if hit_fx:
		world.spawn_fx(hit_fx, global_position, hit_fx_anchor if hit_fx_anchor else self)
	
	_deviate(config.hit_direction_deviation)
	
	_hits_and_blocks_count += 1
	
	if config.max_hits_and_blocks > 0 and _hits_and_blocks_count >= config.max_hits_and_blocks:
		_is_wasted = true
	
	if _is_wasted:
		_dispose()	
			
func _process(delta):
	if not game.paused:
		if _is_launched and not _is_wasted:
			global_position += direction * current_velocity * delta * game.speed
			current_velocity += config.acceleration * delta	
			current_velocity = clampf(current_velocity, config.min_velocity, config.max_velocity)
		
		if cooldown.ready("max_lifetime"):
			_dispose()
		
func _dispose():
	if body != null:
		body.hide()
		
	queue_free()

func _deviate(max_deviation: float):
	var deviation: float = randf_range(-max_deviation, max_deviation)
	var current_angle = tools.rotation_degrees_y_from_direction(direction)
	var new_angle = current_angle + deviation
	direction = tools.angle_to_direction(new_angle)
	look_at(global_position + direction)

func _reflect():
	direction = tools.calculate_reflected_direction(direction, _collision_normal)
	look_at(global_position + direction)

func _update_ray_collision():
	if ray != null and ray.is_colliding():
		_collision_point = ray.get_collision_point()
		_collision_normal = ray.get_collision_normal()
		pass
	else:
		_collision_normal = -direction
		_collision_point = global_position
	pass
