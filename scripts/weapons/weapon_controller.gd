extends Node3D

class_name S2WeaponController

@export var config: RWeaponConfig
@export var keeper: Node3D

var cooldowns: S2CooldownManager = S2CooldownManager.new(true)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func fire(direction: Vector3):
	if cooldowns.ready("fire", true):
		cooldowns.start("fire", 1 / config.fire_rate)
		
		var projectile: S2ProjectileController = tools.get_random_element_from_array(config.projectiles).instantiate()
		
		projectile.keeper = keeper
		projectile.global_position = global_position
		projectile.direction = direction.rotated(Vector3.UP, deg_to_rad(randf_range(-config.spread, config.spread)))
		
		world.add_object(projectile)
		projectile.launch()
	
	pass
