# Author: @sanyabeast
# Date: Feb. 2024

# This script defines a projectile configuration resource.

extends Resource

class_name RProjectileConfig

# Exported variables for customizing projectile behavior.
@export var acceleration: float = 1  # Acceleration of the projectile.
@export var start_velocity: float = 1  # Initial velocity of the projectile.
@export var min_velocity: float = 1  # Minimum velocity of the projectile.
@export var max_velocity: float = 10  # Maximum velocity of the projectile.
@export var max_collisions: int = 1  # Maximum number of collisions the projectile can undergo.
@export var max_lifetime: float = 15  # Maximum lifetime of the projectile.
