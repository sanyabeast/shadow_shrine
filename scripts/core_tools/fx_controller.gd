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
var is_disposed: bool = false

var _particle_systems: Array[GPUParticles3D] = []
var _audio_players: Array[AudioStreamPlayer3D] = []
var _active_content: int = 0

func _init(_config: RFXConfig):
	config = _config
	
func _ready():
	_setup_content()
	if autostart:
		start()
	pass # Replace with function body.

func _to_string():
	return "FX(config: %s)" % config

func start():
	dev.logd(TAG, "starting new FX: %s" % config)
	_launch_content()
	_started_at = get_time()
	_is_started = true

func _traverse(node):
	if node is GPUParticles3D:
		_particle_systems.append(node)
		
	if node is AudioStreamPlayer3D:
		node.bus = "SFX"
		_audio_players.append(node)
		
	# Recursively call this function on all children
	for child in node.get_children():
		_traverse(child)	
	
func _launch_content():
	for ps in _particle_systems:
		if ps is GPUTrail3D:
			ps._old_pos = ps.global_position
			ps.restart()
			
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
			add_child(audio_player)
			
			audio_player.bus = "SFX"
			audio_player.stream = config.audio
			audio_player.panning_strength = config.audio_panning
			audio_player.pitch_scale = _get_variable_pitch_value(config)
			audio_player.max_db = linear_to_db(randf_range(config.audio_volume_min, config.audio_volume_max))
			_audio_players.append(audio_player)
			
			#audio_player.play()
		
		for item in config.content:
			var scene = item.instantiate()
			add_child(scene)
	else:
		dev.logr(TAG, "fail to start FX at %s: no config" % name)
		dispose()
		
	_traverse(self)
	stop_fx()

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

# Called erw frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not is_disposed and _is_started:
		if bound_object != null:
			global_position = bound_object.global_position
			rotation = bound_object.global_rotation
			
		match config.dispose_strategy:
			RFXConfig.EFXDisposeStrategy.Lifetime:
				if get_time() - _started_at >= config.lifetime:
					dispose()
					
			RFXConfig.EFXDisposeStrategy.BoundObject:
				if bound_object == null or not bound_object.visible or not bound_object.is_inside_tree():
					dispose()
					
			RFXConfig.EFXDisposeStrategy.Content:
				dev.logr(TAG, "Content based FX disposing is not implemented yet")

func stop_fx():
	for ps in _particle_systems:
		ps.emitting = false
		if ps is GPUTrail3D:
			ps._old_pos = ps.global_position
	for ap in _audio_players:
		ap.playing = false
			
func dispose():
	is_disposed = true
	dev.logd(TAG, "disposing FX at %s, pool: %s" % [name,  world.use_fx_pool])
	stop_fx()
	if world.use_fx_pool:
		world.fx_pool.push(config.resource_path, self)
	else:
		queue_free()

func restruct():
	#for ps in _particle_systems:
		#ps.emitting = false
		#if ps is GPUTrail3D:
			##ps._old_pos = ps.global_position
			##ps.restart()
	#for ap in _audio_players:
		#ap.stop()
	is_disposed = false
	stop_fx()
	print("restoring fx: %s" % self)
