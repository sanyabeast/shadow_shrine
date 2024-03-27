# Author: @sanyabeast
# Date: Mar. 2024

extends Resource
class_name RMenuSFX

@export_subgroup("♥ Menu SFX")
@export var interaction_sound: AudioStream
@export var submit_sound: AudioStream
@export var cancel_sound: AudioStream
@export var alter_sound: AudioStream

@export_subgroup("♥ Menu SFX ~ Sound Extras")
@export var interaction_sound_pitch_min: float = 0.95
@export var interaction_sound_pitch_max: float = 1.05
@export var submit_sound_pitch_min: float = 0.95
@export var submit_sound_pitch_max: float = 1.05
@export var cancel_sound_pitch_min: float = 0.95
@export var cancel_sound_pitch_max: float = 1.05
@export var alter_sound_pitch_min: float = 0.95
@export var alter_sound_pitch_max: float = 1.05
