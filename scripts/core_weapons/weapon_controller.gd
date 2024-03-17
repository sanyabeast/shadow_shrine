# Author: @sanyabeast
# Date: Feb. 2024

# This script defines a weapon controller for handling firing mechanics.

extends Node3D

class_name GWeaponController
const TAG: String = "WeaponController"

# Exported variable for weapon configuration.
@export var config: RWeaponConfig
# Reference to the keeper node for managing the weapon's ownership.
@export var keeper: Node3D

# Cooldown manager to regulate firing rate.
var cooldowns: GCooldowns = GCooldowns.new(true)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Method to fire a projectile in the specified direction.
func fire(direction: Vector3):
	# Check if the firing cooldown is ready.
	if cooldowns.ready("fire", true):
		# Start the firing cooldown based on the configured fire rate.
		cooldowns.start("fire", 1 / config.fire_rate)
		
		# Instantiate a random projectile from the configured options.
		var projectile: GProjectileController = tools.get_random_element_from_array(config.projectiles).instantiate()
		
		world.add_object(projectile)
		# Set the keeper and initial position of the projectile.
		projectile.keeper = keeper
		# Apply a randomized spread to the firing direction.
		projectile.direction = direction.rotated(Vector3.UP, deg_to_rad(randf_range(-config.spread, config.spread)))
		# Add the projectile to the world and launch it.
		
		projectile.global_position = global_position
		
		projectile.launch()
	
	pass
