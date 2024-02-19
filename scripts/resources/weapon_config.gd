extends Resource

class_name RWeaponConfig


enum EDamageType {
	Projectile,
	Hitscan,
}

@export var damage_type: EDamageType = EDamageType.Projectile
@export var projectiles: Array[PackedScene]
@export var fire_rate: float = 5
