# Author: @sanyabeast
# Date: Feb. 2024

# This script defines a door controller that manages the opening and closing of a door in a 3D game.

extends Area3D
class_name S2DoorController
const TAG: String = "DoorController"

# Exposed variables for the connected body, animation player, and other parameters.
@export var body: Node3D
@export var anim_player: AnimationPlayer

# Direction of the door (North, South, East, West, etc.).
var direction: world.EDirection = world.EDirection.North
# Reference to the room controller to interact with the room.
var room_controller: S2RoomController
# Flag to check if the player has entered the door area.
var has_entered_body: bool = false
# Flag indicating whether the door is currently opened.
var opened: bool = false

# References to various nodes in the scene.
@onready var player_spawn: Node3D = $PlayerSpawn
@onready var entering_area: CollisionShape3D = $EnteringArea
@onready var blocker: StaticBody3D = $Blocker

# Exported variables for door FX configurations.
@export_subgroup("Door FX")
@export var open_fx: RFXConfig
@export var close_fx: RFXConfig

# Cooldown manager for handling activation cooldown.
var cooldowns: S2CooldownManager = S2CooldownManager.new(true)

# Called when the node enters the scene tree for the first time.
func _ready():
	# Start the activation cooldown.
	cooldowns.start("activation_cooldown", 0.1)
	
	# Determine the direction of the door based on its position in the world.
	direction = world.get_node_direction(self)
	
	# Connect signals for body entering and exiting the door area.
	body_entered.connect(handle_body_entered)
	body_exited.connect(handle_body_exited)
	
	# Traverse the scene to find the AnimationPlayer node if it's not set.
	_traverse(self)
	
	# Initialize the door state based on the 'opened' flag.
	if opened:
		open(true)
	else:
		close(true)
	
	# Log the initialization of the door.
	dev.logd(TAG, "door inited: %s" % self)
		
	pass # Replace with function body.

# Recursive function to traverse the scene and find the AnimationPlayer node.
func _traverse(node):
	if anim_player == null and node is AnimationPlayer:
		anim_player = node
		
	# Recursively call this function on all children.
	for child in node.get_children():
		_traverse(child)

# Custom string representation of the DoorController for debugging purposes.
func _to_string():
	return "DoorController(name: %s, direction: %s)" % [name, world.get_direction_pretty_name(direction)]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Function to handle the body entering the door area.
func handle_body_entered(body: Node3D):
	if visible and cooldowns.ready("activation_cooldown"):
		if not has_entered_body:
			# Check if the entering body is the player character.
			if body is S2Character and player_manager.is_player(body):
				has_entered_body = true
				room_controller.handle_player_entered_door_area(self, body)

# Function to handle the body exiting the door area.
func handle_body_exited(body: Node3D):
	if visible:
		if has_entered_body:
			# Check if the exiting body is the player character.
			if body is S2Character and player_manager.is_player(body):
				has_entered_body = false
				room_controller.handle_player_exited_door_area(self, body)

# Function to open the door with an optional silent parameter.
func open(silent = false):
	entering_area.disabled = false
	blocker.process_mode = Node.PROCESS_MODE_DISABLED
	anim_player.play("Open")
	
	# If silent, jump to the end of the animation; otherwise, trigger FX and update the state.
	if silent:
		anim_player.seek(anim_player.current_animation_length)
	else:
		if visible and open_fx:
			world.spawn_fx(open_fx, global_position)
		
	opened = true
	
# Function to close the door with an optional silent parameter.
func close(silent = false):
	entering_area.disabled = true
	blocker.process_mode = Node.PROCESS_MODE_ALWAYS
	anim_player.play("Close")
	
	# If silent, jump to the end of the animation; otherwise, trigger FX and update the state.
	if silent:
		anim_player.seek(anim_player.current_animation_length)
	else:
		if visible and close_fx:
			world.spawn_fx(close_fx, global_position)
			
	opened = false
