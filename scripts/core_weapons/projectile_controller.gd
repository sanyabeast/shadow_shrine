# Author: @sanyabeast
# Date: Feb. 2024


@icon("res://assets/_dev/_icons/dotto-emoji-main-svg/Dotto Emoji345.svg")
extends Area3D

class_name GProjectileController
const TAG: String = "ProjectileController"

@export_subgroup("# Projectile Controller")
@export var config: RProjectileConfig
@export var hit_procedures: Array[GProcedure] = []
@export var ray: RayCast3D
@export var surface_helper: GSurfaceMaterialHelper

@export_subgroup("# Projectile Controller ~ Projectile FX")
@export var launch_fx: RFXConfig
@export var block_fx: RFXConfig
@export var hit_fx: RFXConfig
@export var waste_fx: RFXConfig

@export_subgroup("# Projectile Controller ~ Body")
@export var body: Node3D
@export var hide_body_on_block: bool = true
@export var hide_body_on_hit: bool = true

@export_subgroup("# Projectile Controller ~ Misc")
@export var auto_launch: bool = false
@export var direction: Vector3 = Vector3.FORWARD
@export var keeper: Node3D
@export var pool_key: String = ""

@export_subgroup("# Projectile Controller ~ FX Anchors")
@export var launch_fx_anchor: Node3D
@export var block_fx_anchor: Node3D
@export var hit_fx_anchor: Node3D

var cooldowns: GCooldowns = GCooldowns.new(true)
var current_velocity: float = 0
var weapon: GWeaponController = null

var _is_launched: bool = false
var _hits_and_blocks_count: int = 0
var _is_wasted: bool = false

var _collision_normal: Vector3 = Vector3.ZERO
var _collision_point: Vector3 = Vector3.ZERO

var _is_disposed: bool = false
var _prev_position: Vector3
var _distance_travelled: float = 0
var _prev_weapon_global_pos: Vector3
var _launch_elevation: float = 0
var _use_ballistic: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_handle_body_entered)
	body_exited.connect(_handle_body_exited)
	
	if ray != null:
		ray.add_exception(self)
	
	if auto_launch:
		launch()
		
	# collsiion
	set_collision_layer_value(world.ECollisionBodyType.Character, false)
	set_collision_layer_value(world.ECollisionBodyType.Static, false)
	set_collision_layer_value(world.ECollisionBodyType.Projectile, true)
	set_collision_layer_value(world.ECollisionBodyType.Area, false)
	
	set_collision_mask_value(world.ECollisionBodyType.Character, true)
	set_collision_mask_value(world.ECollisionBodyType.Static, true)
	set_collision_mask_value(world.ECollisionBodyType.Projectile, false)
	set_collision_mask_value(world.ECollisionBodyType.Area, false)
	
	pass # Replace with function body.

func launch():
	if config.bound_to_weapon and weapon != null:
		_prev_weapon_global_pos = weapon.global_position
	
	_use_ballistic = config.use_ballistic and config.ballistic_curve != null
	_launch_elevation = global_position.y
	
	look_at(global_position + direction)
	cooldowns.start("max_lifetime", config.max_lifetime)
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
			if keeper and _hit_body != keeper and characters.should_hit(keeper, _hit_body):
				#dev.logd(TAG, 'projectile hit character %s' % _hit_body)
				_handle_hit(_hit_body)
		else:
			#dev.logd(TAG, 'projectile hit something %s' % _hit_body)
			_handle_block(_hit_body)
	
func _handle_body_exited(_hit_body):
	pass

func _handle_block(_hit_body):
	_update_ray_collision()
	
	if hide_body_on_block and body:
		body.hide()
		
	if block_fx:
		world.spawn_fx(block_fx, global_position)	
		
	if surface_helper != null:
		surface_helper.enter_state("hit", 0)
		surface_helper.enter_state("default", 0.25)
		
	_hits_and_blocks_count += 1	
	
	_reflect()
	_deviate(config.block_direction_deviation)
		
	if config.max_hits_and_blocks > 0 and _hits_and_blocks_count >= config.max_hits_and_blocks:
		_is_wasted = true
			
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
		world.spawn_fx(hit_fx, global_position)
	
	if surface_helper != null:
		surface_helper.enter_state("hit", 0)
		surface_helper.enter_state("default", 0.25)
	
	_deviate(config.hit_direction_deviation)
	
	_hits_and_blocks_count += 1
	
	if config.max_hits_and_blocks > 0 and _hits_and_blocks_count >= config.max_hits_and_blocks:
		_is_wasted = true
	
			
func _process(delta):
	if not game.paused:
		if _is_launched:
			if _is_wasted:
				if not _is_disposed:
					dispose()
			else:
				current_velocity += config.acceleration * delta	
				current_velocity = clampf(current_velocity, config.min_velocity, config.max_velocity)
			
				if cooldowns.ready("max_lifetime"):
					_is_wasted = true
				
				if config.max_distance_travelled > 0 and _distance_travelled >=  config.max_distance_travelled:
					_is_wasted = true
					
			
func _physics_process(delta):
	if not game.paused:
		if _is_launched and not _is_wasted:
			if config.bound_to_weapon:
				var weapon_pos_delta: Vector3 = weapon.global_position - _prev_weapon_global_pos
				_prev_weapon_global_pos = weapon.global_position
				
				global_position += weapon_pos_delta + (direction * current_velocity * delta * game.speed)
				_distance_travelled += (weapon_pos_delta + (direction * current_velocity * delta * game.speed)).length()
			else:
				var pos_delta: Vector3 = direction * current_velocity * delta * game.speed
				global_position += pos_delta
				_distance_travelled += (Vector3(pos_delta.x, 0., pos_delta.z)).length()
				
				if _use_ballistic:
					global_position.y = _launch_elevation + config.ballistic_curve.sample_baked(
						tools.reverse_lerp(_distance_travelled, 0, config.ballistic_distance)
					) * config.ballistic_elevation
					
				
			
func dispose():
	_is_disposed = true
	
	if waste_fx:
		world.spawn_fx(waste_fx, global_position)
	
	if body != null:
		body.hide()
		
	if world.use_projectile_pool and pool_key != "":
		world.projectile_pool.push(pool_key, self)
	else:
		queue_free()
	
func reborn():
	_is_launched = false
	_is_wasted = false
	_hits_and_blocks_count = 0
	current_velocity = 0
	_distance_travelled = 0
	cooldowns.reset()
	_is_disposed = false
	
	if body != null:
		body.show()

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
