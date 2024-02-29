extends Node3D

class_name S2FX
const TAG: String = "FX"

@export var config: RFXConfig
@export var autostart: bool = false

var _is_started: bool = false
var _started_at: float

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
	_started_at = get_time()
	_is_started = true
	
func _setup_content():
	if config:
		if config.audio != null:
			var audio_player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
			audio_player.stream = config.audio
			audio_player.pitch_scale = randf_range(config.audio_pitch_min, config.audio_pitch_max)
			audio_player.play()
		
		for item in config.content:
			var scene = item.instantiate()
			add_child(scene)
	else:
		dev.logr(TAG, "fail to start FX at %s: no config" % name)
		_die()
	
func get_time()->float:
	if config and config.use_game_time:
		return game.get_time()
	else:
		return tools.get_time()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _is_started:
		if get_time() - _started_at >= config.lifetime:
			_die()

func _die():
	dev.logd(TAG, "destroying FX at %s" % name)
	queue_free()
