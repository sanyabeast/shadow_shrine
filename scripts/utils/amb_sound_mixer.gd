extends AudioStreamPlayer3D
class_name S2AmbientStreamMixer

const TAG: String = "AmbientStreamMixer"

const min_volume_db: float = -50
const max_volume_db: float = 0

@export var playlist: Array[AudioStream] = []
@export var track_index: int = 0

var is_playing: bool = false
var fade_time: float = 0

func _init(_playlist: Array[AudioStream] = [], _track_index: int = 0, _is_playing: bool = false):
	playlist = _playlist
	track_index = _track_index
	is_playing = _is_playing
	
# Called when the node enters the scene tree for the first time.
func _ready():
	panning_strength = 0
	finished.connect(_handle_stream_player_finished)
	set_track(track_index)
	if is_playing:
		play_mix(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var fade_speed = (max_volume_db - min_volume_db) / fade_time
	
	if is_playing and volume_db < 0:
		volume_db = move_toward(volume_db, 0, fade_speed * delta)
		
	if not is_playing and volume_db > min_volume_db:
		volume_db = move_toward(volume_db, min_volume_db, fade_speed * delta)
	
	if not is_playing and volume_db <= min_volume_db:
		stop()
		
	pass

func _handle_stream_player_finished():
	dev.logd(TAG, "finsihed playing: %s" % stream)
	next_track()
	pass

func play_mix(fade_duration: float = 0.5):
	is_playing = true
	fade_time = fade_duration
	if fade_duration == 0:
		volume_db = 0
	play()
	pass

func pause_mix(fade_duration: float = 0):
	is_playing = false
	fade_time = fade_duration
	if fade_duration == 0:
		volume_db = min_volume_db
		stop()
	
func next_track():
	if playlist.size() > 0:
		track_index = (track_index + 1) % playlist.size()
		set_track(track_index)
		
func set_track(index: int):
	if playlist.size() > 0:
		dev.logd(TAG, "setting player active stream to index: %s, stream: %s" % [index, stream])
		stream = playlist[index]
		
		if is_playing:
			play_mix(0)
	else:
		dev.logr(TAG, "failed to set_track at %s, playlist is empty" % self)
