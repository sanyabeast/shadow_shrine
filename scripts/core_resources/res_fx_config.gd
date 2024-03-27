# Author: @sanyabeast
# Date: Feb. 2024

# This script defines a resource configuration for special effects (FX).

extends Resource
class_name RFXConfig

# Enumeration for different strategies to dispose of FX.
enum EFXDisposeStrategy {
	Lifetime,       # Dispose after a specified lifetime.
	BoundObject,    # Dispose when bound object is removed.
	Content         # Dispose after playing all content.
}

# Exported variables for configuring audio and content of the FX.
@export_subgroup("♥ FXConfig")
@export var audio: AudioStream  # Audio stream for the FX.
@export var audio_pitch_min: float = 1  # Minimum pitch for audio playback.
@export var audio_pitch_max: float = 1  # Maximum pitch for audio playback.
@export var audio_volume_min: float = 1  # Minimum volume for audio playback.
@export var audio_volume_max: float = 1  # Maximum volume for audio playback.
@export var audio_panning: float = 0.5
@export var content: Array[PackedScene]  # Array of content (PackedScenes) for the FX.
@export var use_game_time: bool = true  # Flag to determine whether to use game time.

# Exported variables for configuring the disposal of FX.
@export_subgroup("♥ FXConfig ~ Disposing")
@export var dispose_strategy: EFXDisposeStrategy = EFXDisposeStrategy.Lifetime  # Strategy for FX disposal.
@export var lifetime: float = 5  # Lifetime of the FX when using the 'Lifetime' disposal strategy.

# Method to represent the FX configuration as a string.
func _to_string():
	return "FXConfig(audio: %s, content: %s)" % [audio, content.size()]
