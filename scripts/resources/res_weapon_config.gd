# Author: @sanyabeast
# Date: Feb. 2024

extends Resource
class_name RWeaponConfig

enum EDamageType {
	Projectile,
	Hitscan,
}

@export_subgroup("♥ WeaponConfig")
@export var damage_type: EDamageType = EDamageType.Projectile
@export var projectiles: Array[PackedScene]
@export var fire_rate: float = 5
@export var spread: float = 0
@export var ideal_distance_min: float =1
@export var ideal_distance_max: float = 4
