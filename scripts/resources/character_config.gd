extends Resource

class_name RCharacterConfig

@export var health: float = 3
@export var speed: float = 5
@export var default_weapon: RWeaponConfig
@export var protection: float = 1
@export var damage: float = 1
@export var mass: float = 1

@export_subgroup("NPC")
@export var patrolling_distance: float = 5
@export var target_position_refresh_timeout: float = 3

@export_subgroup("Character FX")
@export var hurt_fx: RFXConfig
@export var death_fx: RFXConfig
