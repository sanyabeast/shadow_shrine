extends Resource

class_name RFXConfig

enum EFXDisposeStrategy {
	Lifetime,
	BoundObject,
	Content
}

@export var audio: AudioStream
@export var audio_pitch_min: float = 1
@export var audio_pitch_max: float = 1 
@export var content: Array[PackedScene]
@export var use_game_time: bool = true

@export_subgroup("Disposing")
@export var dispose_strategy: EFXDisposeStrategy = EFXDisposeStrategy.Lifetime
@export var lifetime: float = 5


func _to_string():
	return "FXConfig(audio: %s, content: %)" % [audio, content.size()]
