# Author: @sanyabeast
# Date: Feb. 2024

# This script defines a projectile configuration resource.

extends Resource
class_name RProjectileConfig

# Exported variables for customizing projectile behavior.
@export_subgroup("♥ ProjectileConfig")
@export var acceleration: float = 1  # Acceleration of the projectile.
@export var start_velocity: float = 1  # Initial velocity of the projectile.
@export var min_velocity: float = 1  # Minimum velocity of the projectile.
@export var max_velocity: float = 10  # Maximum velocity of the projectile.
@export var max_lifetime: float = 15  # Maximum lifetime of the projectile.
@export var max_distance_travelled: float = -1
@export var max_hits_and_blocks: float = 1  # Maximum times projectile can affect target
@export var hit_direction_deviation: float = 15
@export var block_direction_deviation: float = 5
@export var bound_to_weapon: bool = false

@export_subgroup("♥ ProjectileConfig ~ Ballistics")
@export var use_ballistic: bool = false
@export var ballistic_distance: float = 3
@export var ballistic_elevation: float = 3
@export var ballistic_curve: Curve
