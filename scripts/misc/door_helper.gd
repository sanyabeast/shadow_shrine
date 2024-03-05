extends Area3D

class_name S2DoorController

const TAG: String = "DoorController"

@export var body: Node3D
@export var anim_player: AnimationPlayer

var direction: world.EDirection = world.EDirection.North
var room_controller: S2RoomController
var has_entered_body: bool = false
var opened: bool = false

@onready var player_spawn: Node3D = $PlayerSpawn
@onready var entering_area: CollisionShape3D = $EnteringArea
@onready var blocker: StaticBody3D = $Blocker

@export_subgroup("Door FX")
@export var open_fx: RFXConfig
@export var close_fx: RFXConfig


# Called when the node enters the scene tree for the first time.
func _ready():
	direction = world.get_node_direction(self)
	body_entered.connect(handle_body_entered)
	body_exited.connect(handle_body_exited)
	
	_traverse(self)
	
	if opened:
		open(true)
	else:
		close(true)
	
	dev.logd(TAG, "door inited: %s" % self)
		
	pass # Replace with function body.

func _traverse(node):
	if anim_player == null and node is AnimationPlayer:
		anim_player = node
		
	# Recursively call this function on all children
	for child in node.get_children():
		_traverse(child)

func _to_string():
	return "DoorController(name: %s, direction: %s)" % [name, world.get_direction_pretty_name(direction)]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func handle_body_entered(body: Node3D):
	if visible:
		if not has_entered_body:
			if body is S2Character and player.is_player(body):
				print("entered %s" % self)
				has_entered_body = true
				room_controller.handle_player_entered_door_area(self, body)
	
func handle_body_exited(body: Node3D):
	if visible:
		if has_entered_body:
			if body is S2Character and player.is_player(body):
				has_entered_body = false
				room_controller.handle_player_exited_door_area(self, body)

func open(silent = false):
	entering_area.disabled = false
	blocker.process_mode = Node.PROCESS_MODE_DISABLED
	anim_player.play("Open")
	
	if silent:
		anim_player.seek(anim_player.current_animation_length)
	else:
		if open_fx:
			world.spawn_fx(open_fx, global_position)
		
	opened = true
	
func close(silent = false):
	entering_area.disabled = true
	blocker.process_mode = Node.PROCESS_MODE_ALWAYS
	anim_player.play("Close")
	
	if silent:
		anim_player.seek(anim_player.current_animation_length)
	else:
		if close_fx:
			world.spawn_fx(close_fx, global_position)
			
	opened = false
