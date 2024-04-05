# Author: @sanyabeast
# Date: Feb. 2024

extends Node3D

class_name GFXController
var TAG: String = "FX"

@export var config: RFXConfig
@export var bound_object: Node3D
@export var autostart: bool = false

var _is_started: bool = false
var _started_at: float
var is_disposed: bool = false
var is_finished: bool = false

var _particle_systems: Array[GPUParticles3D] = []
var _audio_players: Array[AudioStreamPlayer3D] = []
var _active_content_count: int = 0
var _active_particle_systems_count: int = 0
var _active_audio_players_count: int = 0
var _one_shot_map: Dictionary = {}

var _cooldowns := GCooldowns.new(true)

func _init(_config: RFXConfig):
	config = _config
	
func _ready():
	_setup_content()
	name = "fx"
	if autostart:
		start()
	pass # Replace with function body.

func _to_string():
	return "FX(config: %s)" % config

func start():
	#dev.logd(TAG, "starting new FX: %s" % config)
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
		ps.restart()
			
	for ap in _audio_players:
		ap.play()
		
func _check_active_content_count():
	var count: int = 0
	_active_particle_systems_count = 0
	_active_audio_players_count = 0
	
	for ps in _particle_systems:
		if ps.emitting:
			count += 1
			_active_particle_systems_count += 1
			
	for ap in _audio_players:
		if ap.playing:
			count += 1
			_active_audio_players_count += 1
	
	_active_content_count = count
	_cooldowns.start("check_active_content_count", 1)
	
func _setup_content():
	if config:
		if config.audio != null or config.audio_variants.size() > 0:
			var audio_player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
			add_child(audio_player)
			
			audio_player.bus = "SFX"
			
			if config.audio_variants.size() > 0:
				audio_player.stream = tools.get_random_element_from_array(config.audio_variants)
			else:
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
	
	for p in _particle_systems:
		_one_shot_map[p.get_instance_id()] = p.one_shot
	
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
	if  _is_started:
		if not visible:
			visible = true
			
		if bound_object != null and bound_object.is_inside_tree():
			global_position = bound_object.global_position
			rotation = bound_object.global_rotation			
		
		if not is_finished:
			match config.dispose_strategy:
				RFXConfig.EFXDisposeStrategy.Lifetime:
					if get_time() - _started_at >= config.lifetime:
						finish()
						return
						
				RFXConfig.EFXDisposeStrategy.BoundObject:
					if bound_object == null or not bound_object.is_inside_tree():
						finish()
						return
						
				RFXConfig.EFXDisposeStrategy.Content:
					if _cooldowns.ready_or_start("check_active_content_count", 1, true):
						_check_active_content_count()
						
					dev.logr(TAG, "Content based FX disposing is not implemented yet")
		else:
			if not is_disposed:
				if _cooldowns.ready_or_start("check_active_content_count", 1, true):
					_check_active_content_count()
				
				if _active_particle_systems_count == 0:
					if _cooldowns.ready_or_start("dispose_after_finish", 2, false):
						dispose()
			pass

func _physics_process(delta):
	pass
			
func dispose():
	is_disposed = true
	
	visible = false
	if world.use_fx_pool:
		world.fx_pool.push(config.resource_path, self)
	else:
		queue_free()

func reborn():
	is_disposed = false
	is_finished = false
	
	for ps in _particle_systems:
		ps.one_shot = _one_shot_map[ps.get_instance_id()]

func finish():
	is_finished = true	
	_set_all_one_shot()

func _set_all_one_shot():
	for ps in _particle_systems:
		ps.one_shot = true
