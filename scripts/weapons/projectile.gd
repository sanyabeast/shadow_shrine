# Author: @sanyabeast
# Date: Feb. 2024

extends Area3D

class_name S2ProjectileController

const TAG: String = "ProjectileController"

@export var config: RProjectileConfig

@export_subgroup("Character Effects")
@export var damage: float = 1
@export var impulse: float = 1

@export_subgroup("Projectile FX")
@export var launch_fx: RFXConfig
@export var block_fx: RFXConfig
@export var hit_fx: RFXConfig

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

var cooldown: S2CooldownManager = S2CooldownManager.new(true)
var current_velocity: float = 0

var _is_launched: bool = false
var _is_wasted: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_handle_body_entered)
	body_exited.connect(_handle_body_exited)
	
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
	
	pass

func _handle_body_entered(body):
	if not _is_wasted:
		if body is S2Character:
			if keeper and body != keeper:
				dev.logd(TAG, 'projectile hit character %s' % body)
				_handle_hit(body)
		else:
			dev.logd(TAG, 'projectile hit something %s' % body)
			_handle_block()
	
func _handle_body_exited(body):
	pass

func _handle_block():
	_is_wasted = true
	
	if hide_body_on_block and body:
		body.hide()
		
	if block_fx:
		world.spawn_fx(block_fx, global_position, block_fx_anchor if block_fx_anchor else self, global_rotation)	
		
	_dispose()	
		
	pass
	
func _handle_hit(hit_character: S2Character):
	_is_wasted = true
	
	if damage > 0:
		hit_character.commit_damage(damage)

	if impulse > 0:
		hit_character.commit_impulse(-basis.z, impulse)
		
	if hide_body_on_hit and body:
		body.hide()
	
	if hit_fx:
		world.spawn_fx(hit_fx, global_position, hit_fx_anchor if hit_fx_anchor else self)
	
	_dispose()
	
	pass

func _process(delta):
	if not game.paused:
		if _is_launched and not _is_wasted:
			global_position += direction * current_velocity * delta * game.speed
			current_velocity += config.acceleration * delta	
			current_velocity = clampf(current_velocity, config.min_velocity, config.max_velocity)
		
		if cooldown.ready("max_lifetime"):
				_dispose()
		
	pass


func _dispose():
	queue_free()
