# Author: @sanyabeast
# Date: Feb. 2024

extends Node3D

class_name GFXController
const TAG: String = "FX"

@export var config: RFXConfig
@export var bound_object: Node3D
@export var autostart: bool = false

var _is_started: bool = false
var _started_at: float
var _is_disposed: bool = false

var _particle_systems: Array[GPUParticles3D] = []
var _audio_players: Array[AudioStreamPlayer] = []

var _active_content: int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	if autostart:
		start()
	pass # Replace with function body.

func _to_string():
	return "FX(config: %s)" % config

func start():
	dev.logd(TAG, "starting new FX: %s" % config)
	_setup_content()
	_launch_content()
	_started_at = get_time()
	_is_started = true
	
func _traverse(node):
	if node is GPUParticles3D:
		_particle_systems.append(node)
		
	if node is AudioStreamPlayer:
		node.bus = "SFX"
		_audio_players.append(node)
		
	# Recursively call this function on all children
	for child in node.get_children():
		_traverse(child)	
	
func _launch_content():
	for ps in _particle_systems:
		ps.emitting = true
			
	for ap in _audio_players:
		ap.play()
	
func _check_active_content():
	var count: int = 0
	
	for ps in _particle_systems:
		if ps.emitting:
			count += 1
			
	for ap in _audio_players:
		if ap.playing:
			count += 1
	
	_active_content = count
	
func _setup_content():
	if config:
		if config.audio != null:
			var audio_player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
			audio_player.bus = "SFX"
			audio_player.stream = config.audio
			audio_player.pitch_scale = _get_variable_pitch_value(config)
			audio_player.volume_db = linear_to_db(randf_range(config.audio_volume_min, config.audio_volume_max))

			add_child(audio_player)
			audio_player.play()
		
		for item in config.content:
			var scene = item.instantiate()
			add_child(scene)
	else:
		dev.logr(TAG, "fail to start FX at %s: no config" % name)
		_dispose()
		
	_traverse(self)	

func _get_variable_pitch_value(config: RFXConfig) -> float:
	var current_pitch_value: float = (
		tools.sin_normalized(game.time * 1.25) + 
		tools.sin_normalized(game.time * 3.00) + 
		tools.sin_normalized(game.time * 5.25)
	) / 3
	var result: float = lerpf(config.audio_pitch_min, config.audio_pitch_max, current_pitch_value)
	return result
	
func get_time()->float:
	if config and config.use_game_time:
		return game.get_time()
	else:
		return tools.get_time()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _is_started:
		if bound_object != null:
			global_position = bound_object.global_position
			rotation = bound_object.global_rotation
		
		if not _is_disposed:
			match config.dispose_strategy:
				RFXConfig.EFXDisposeStrategy.Lifetime:
					if get_time() - _started_at >= config.lifetime:
						_dispose()
						
				RFXConfig.EFXDisposeStrategy.BoundObject:
					if bound_object == null:
						_dispose()
						
				RFXConfig.EFXDisposeStrategy.Content:
					dev.logr(TAG, "Content based FX disposing is not implemented yet")
			
func _dispose():
	dev.logd(TAG, "disposing FX at %s" % name)
	_is_disposed = true
	queue_free()
