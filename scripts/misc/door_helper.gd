extends Area3D

class_name S2DoorController

@export var direction: world.EDirection = world.EDirection.North
var room_controller: S2RoomController
var has_entered_body: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(handle_body_entered)
	body_exited.connect(handle_body_exited)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func handle_body_entered(body: Node3D):
	if not has_entered_body:
		if body is S2Character and player.is_player(body):
			has_entered_body = true
			room_controller.handle_player_entered_door_area(self, body)
	
func handle_body_exited(body: Node3D):
	if has_entered_body:
		if body is S2Character and player.is_player(body):
			has_entered_body = false
			room_controller.handle_player_exited_door_area(self, body)
