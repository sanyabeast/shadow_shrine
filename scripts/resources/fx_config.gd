extends Resource

class_name RFXConfig

@export var lifetime: float = 5
@export var audio: AudioStream
@export var audio_pitch_min: float = 1
@export var audio_pitch_max: float = 1 
@export var content: Array[PackedScene]
@export var use_game_time: bool = true

func _to_string():
	return "FXConfig(life: %s, audio: %s, content: %)" % [lifetime, audio.resource_path, content.size()]
