extends Area3D

class_name S2ProjectileController

const TAG: String = "ProjectileController"

@export var config: RProjectileConfig

@export_category("Projectile Audio")
@export_subgroup("Launch Audio")
@export var launch_audio_stream: AudioStreamPlayer3D
@export var launch_audio_pitch_min: float = 1
@export var launch_audio_pitch_max: float = 1

@export_subgroup("Block Audio")
@export var block_audio_stream: AudioStreamPlayer3D
@export var block_audio_pitch_min: float = 1
@export var block_audio_pitch_max: float = 1

@export_subgroup("Hit Audio")
@export var hit_audio_stream: AudioStreamPlayer3D
@export var hit_audio_pitch_min: float = 1
@export var hit_audio_pitch_max: float = 1

@export_subgroup("Body")
@export var body: Node3D
@export var hide_body_on_block: bool = true
@export var hide_body_on_hit: bool = true

@export_subgroup("Misc")
@export var auto_launch: bool = false
@export var direction: Vector3 = Vector3.FORWARD
@export var keeper: Node3D

var cooldown: S2CooldownManager = S2CooldownManager.new()
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
	
	if launch_audio_stream:
		launch_audio_stream.pitch_scale = randf_range(launch_audio_pitch_min, launch_audio_pitch_max)
		launch_audio_stream.play()
	
	pass

func _handle_body_entered(body):
	print(body)
	
	if not _is_wasted:
		if body is S2Character:
			if keeper and body != keeper:
				dev.logd(TAG, 'projectile hit character %s' % body)
				_handle_hit()
		else:
			dev.logd(TAG, 'projectile hit something %s' % body)
			_handle_block()
	
func _handle_body_exited(body):
	print(body)

func _handle_block():
	_is_wasted = true
	
	if hide_body_on_block and body:
		body.hide()
	
	if block_audio_stream:
		block_audio_stream.pitch_scale = randf_range(block_audio_pitch_min, block_audio_pitch_max)
		block_audio_stream.play()
		
	pass
	
func _handle_hit():
	if hide_body_on_hit and body:
		body.hide()
		
	if hit_audio_stream:
		hit_audio_stream.pitch_scale = randf_range(hit_audio_pitch_min, hit_audio_pitch_max)
		hit_audio_stream.play()
	
	pass

func _process(delta):
	
	if _is_launched:
		if cooldown.ready("max_lifetime"):
			queue_free()
			
		global_position += -basis.z * current_velocity * delta
		
		current_velocity += config.acceleration * delta	
		current_velocity = clampf(current_velocity, config.min_velocity, config.max_velocity)
		
	pass
