# Author: @sanyabeast
# Date: Feb. 2024

# This script defines a resource configuration for character attributes.

extends Resource

class_name RCharacterConfig

# Exported variables for customizing character attributes.
@export var health: float = 3  # Health points of the character.
@export var speed: float = 5  # Movement speed of the character.
@export var default_weapon: RWeaponConfig  # Default weapon configuration for the character.
@export var protection: float = 1  # Protection factor against damage.
@export var damage: float = 1  # Base damage dealt by the character.
@export var mass: float = 1  # Mass of the character.

# Exported variables for NPC-specific settings.
@export_subgroup("NPC")
@export var patrolling_distance: float = 5  # Distance for patrolling behavior.
@export var target_position_refresh_timeout: float = 3  # Timeout for refreshing the target position.

@export var walk_direction_degrees_change_speed: float = 90
@export var walk_power_change_speed: float = 2

@export var walk_direction_sinus_rate: float = 1
@export var walk_direction_sinus_power: float = 0

@export var walk_power_sinus_min_power: float = 0.5
@export var walk_power_sinus_rate: float = 2
@export var walk_power_sinus_power: float = 0


# Exported variables for character special effects.
@export_subgroup("Character FX")
@export var hurt_fx: RFXConfig  # FX configuration for hurt state.
@export var death_fx: RFXConfig  # FX configuration for death state.
