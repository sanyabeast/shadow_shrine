extends Resource

class_name RCharacterConfig

@export var speed: float = 5
@export var default_weapon: RWeaponConfig

@export_subgroup("NPC")
@export var patrolling_distance: float = 5
@export var target_position_refresh_timeout: float = 3
