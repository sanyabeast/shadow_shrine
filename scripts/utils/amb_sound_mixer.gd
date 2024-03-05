extends Node3D
class_name S2AmbientSoundMixer
const TAG: String = "AmbientSoundMixer"

static var instance: S2AmbientSoundMixer

enum EAmbientSoundCategory {
	A,
	B,
	C,
	D
}

@export var category: EAmbientSoundCategory = EAmbientSoundCategory.A
@export var a: Array[AudioStream] = []
@export var b: Array[AudioStream] = []
@export var c: Array[AudioStream] = []
@export var d: Array[AudioStream] = []

var _stream_player: AudioStreamPlayer3D

var _has_any_streams: bool = false
var _current_stream: AudioStream
var _stream_player_playing: bool = false
var _prev_payback_started_at: float = 0
var _theme_index: int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	_check_streams()
	
	_stream_player = AudioStreamPlayer3D.new()
	_stream_player.panning_strength = 0
	_stream_player.finished.connect(_handle_stream_player_finished)
	
	add_child(_stream_player)
	
	set_category(EAmbientSoundCategory.A)
	S2AmbientSoundMixer.instance = self
	pass # Replace with function body.

func set_category(_category: EAmbientSoundCategory):
	dev.logd(TAG, "setting ambient sound category to %s" % _category)
	category = _category
	next_theme()

func next_theme():
	if _has_any_streams:
		_theme_index += 1
		dev.logd(TAG, "prepare to switch to the next theme in category: %s, theme index: %s" % [category, _theme_index])
		
		var _streams_list: Array[AudioStream] = []
		match category:
			EAmbientSoundCategory.A:
				_streams_list = a
			EAmbientSoundCategory.B:
				_streams_list = b
			EAmbientSoundCategory.C:
				_streams_list = c
			EAmbientSoundCategory.D:
				_streams_list = d
				
		if _streams_list.size() == 0:
			dev.logd(TAG, "failed to found stream from category %s, trying to pick something from all streams: %s" % [category, _streams_list])
			_streams_list = a + b + c + d
			
		_current_stream = _streams_list[_theme_index % _streams_list.size()]
		dev.logd(TAG, "setting player active stream to %s" % _current_stream)
		_stream_player.stream = _current_stream
		_stream_player.play()
		_prev_payback_started_at = tools.get_time()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#if _has_any_streams and not _stream_player.playing:
		#next_theme()
	pass

func _check_streams():
	var streams_count: int = (a + b + c + d).size()
	dev.logd(TAG, "streams checked, total count: %s" % streams_count)
	_has_any_streams = streams_count > 0

func _handle_stream_player_finished():
	dev.logd(TAG, "finsihed playing: %s" % _current_stream)
	next_theme()
	pass
