# Author: @sanyabeast
# Date: Feb. 2024

# This script defines an ambient sound player using AudioStreamPlayer.

extends AudioStreamPlayer
class_name GAmbientPlaylistPlayer

# Constant tag for logging and identification purposes.
const TAG: String = "AmbientPlaylistPlayer"

# Constants for volume control.
const min_volume_db: float = -50
const min_volume_db_stop: float = -49
const max_volume_db: float = 0

# Exported variables for playlist and track management.
@export var playlist: Array[AudioStream] = []  # Array of audio streams for the playlist.
@export var track_index: int = 0  # Index of the currently playing track.

# Variables for tracking the player's state.
var is_playing: bool = false
var fade_time: float = 0

# Constructor to initialize the player with a playlist, track index, and play state.
func _init(_playlist: Array[AudioStream] = [], _track_index: int = 0, _is_playing: bool = false):
	playlist = _playlist
	track_index = _track_index
	is_playing = _is_playing
	bus = "Music"

# Called when the node enters the scene tree for the first time.
func _ready():
	finished.connect(_handle_stream_player_finished)
	set_track(track_index)
	if is_playing:
		play_mix(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Calculate fade speed based on fade time.
	var fade_speed = (max_volume_db - min_volume_db) / fade_time
	
	# Adjust volume based on play state and fade speed.
	if is_playing and volume_db < 0:
		volume_db = move_toward(volume_db, 0, fade_speed * delta)
		
	if not is_playing and volume_db > min_volume_db:
		volume_db = move_toward(volume_db, min_volume_db, fade_speed * delta)
	
	# Stop playing when volume reaches the minimum and is not playing.
	if not is_playing and volume_db <= min_volume_db:
		stop()
	
	pass

# Callback for handling when the current stream finishes playing.
func _handle_stream_player_finished():
	dev.logd(TAG, "finished playing: %s" % stream)
	next_track()
	pass

# Method to start playing with optional fade duration.
func play_mix(fade_duration: float = 0.5):
	is_playing = true
	fade_time = fade_duration
	if fade_duration == 0:
		volume_db = 0
	play()
	pass

# Method to pause playback with optional fade duration.
func pause_mix(fade_duration: float = 0):
	is_playing = false
	fade_time = fade_duration
	if fade_duration == 0:
		volume_db = min_volume_db_stop
		stop()

# Method to move to the next track in the playlist.
func next_track():
	if playlist.size() > 0:
		track_index = (track_index + 1) % playlist.size()
		set_track(track_index)

# Method to set the active track based on the provided index.
func set_track(index: int):
	if playlist.size() > 0:
		dev.logd(TAG, "setting player active stream to index: %s, stream: %s" % [index, stream])
		stream = playlist[index]
		
		if is_playing:
			play_mix(0)
	else:
		dev.logr(TAG, "failed to set_track at %s, playlist is empty" % self)
