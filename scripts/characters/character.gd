extends CharacterBody3D

class_name S2Character

const SPEED = 5.0

@onready var body: Node3D = $Body
@onready var aim_rig: Node3D = $Aim

@export_subgroup("Player Mode")
@export var use_as_player: bool = false

@export_subgroup("NPC Mode")
@export var is_friendly: bool = false

var move_direction: Vector3 = Vector3.FORWARD
var aim_direction: Vector3 = Vector3.FORWARD

func _ready():
	if use_as_player:
		player.set_active(self)

func _physics_process(delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var move_input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var aim_input_direction = Input.get_vector("shoot_left", "shoot_right", "shoot_up", "shoot_down")
	
	move_direction = Vector3(move_input_direction.x, 0., move_input_direction.y)
	aim_direction = Vector3(aim_input_direction.x, 0, aim_input_direction.y)
	
	velocity.x = move_direction.x * SPEED
	velocity.z = move_direction.z * SPEED
	velocity.y = 0
	
	move_and_slide()
	
	global_position.y = 0
	
	
func rotate_body(delta):
	 # Rotate the body toward the move direction if not aiming
	if aim_direction.length_squared() == 0:
		if move_direction.length_squared() > 0:
			body.look_at(body.global_position + move_direction, Vector3.UP)
	else:
		body.look_at(body.global_position + aim_direction, Vector3.UP)
		
	# Always rotate the aim node toward the aim direction
	if aim_direction.length_squared() > 0:
		aim_rig.look_at(aim_rig.global_position + aim_direction, Vector3.UP)


func _process(delta):
	#print("move direction: %s" % move_direction)
	#print("aim direction: %s" % aim_direction)
	
	rotate_body(delta)
	
	pass
	#aim_rig.rotation_degrees.y = _target_aim_rotation
