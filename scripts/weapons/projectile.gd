extends Area3D

class_name S2ProjectileController

@export var config: RProjectileConfig
@export var auto_launch: bool = false
@export var direction: Vector3 = Vector3.FORWARD

var cooldown: S2CooldownManager = S2CooldownManager.new()
var current_velocity: float = 0
var _is_launched: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_handle_body_entered)
	body_exited.connect(_handle_body_exited)
	
	if auto_launch:
		launch()
	
	pass # Replace with function body.

func launch():
	look_at(global_position + direction)
	cooldown.start("max_lifetime", config.max_lifetime)
	current_velocity = config.start_velocity
	_is_launched = true
	pass

func _handle_body_entered(body):
	print(body)
	
func _handle_body_exited(body):
	print(body)

func _process(delta):
	
	if _is_launched:
		if cooldown.ready("max_lifetime"):
			queue_free()
			
		global_position += -basis.z * current_velocity * delta
		
		current_velocity += config.acceleration * delta	
		current_velocity = clampf(current_velocity, config.min_velocity, config.max_velocity)
		
	pass
