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

@export var open_audio_stream: AudioStreamPlayer3D
@export var close_audio_stream: AudioStreamPlayer3D


# Called when the node enters the scene tree for the first time.
func _ready():
	direction = world.get_node_direction(self)
	body_entered.connect(handle_body_entered)
	body_exited.connect(handle_body_exited)
	
	if opened:
		open()
	else:
		close(true)
	
	dev.logd(TAG, "door inited: %s" % self)
		
	pass # Replace with function body.

func _to_string():
	return "DoorController(name: %s, direction: %s)" % [name, world.get_direction_pretty_name(direction)]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func handle_body_entered(body: Node3D):
	
	if not has_entered_body:
		if body is S2Character and player.is_player(body):
			print("entered %s" % self)
			has_entered_body = true
			room_controller.handle_player_entered_door_area(self, body)
	
func handle_body_exited(body: Node3D):
	if has_entered_body:
		if body is S2Character and player.is_player(body):
			has_entered_body = false
			room_controller.handle_player_exited_door_area(self, body)

func open():
	entering_area.disabled = false
	blocker.process_mode = Node.PROCESS_MODE_DISABLED
	#body.hide()
	anim_player.play("Open")
	
	if open_audio_stream:
		open_audio_stream.play()
	
	opened = true
	
func close(skip_effects = false):
	entering_area.disabled = true
	blocker.process_mode = Node.PROCESS_MODE_ALWAYS
	if not skip_effects:
		anim_player.play("Close")
	
		if close_audio_stream:
			close_audio_stream.play()	
			
	#body.show()
	opened = false
