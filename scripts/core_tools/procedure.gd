# Author: @sanyabeast
# Date: Mar. 2024

@icon("res://assets/_dev/_icons/35.png")
extends Node
class_name GProcedure
var TAG: String = "Procedure"

@export_subgroup("FX")
@export var start_fx: RFXConfig

@export_subgroup("Tasking")
@export var schedule_to_game_tasks: bool = false
@export var schedule_to_app_tasks: bool = false
@export var schedule_task_duration: float = 1

# placeholder playload values
var position: Vector3 = Vector3.ZERO
var direction: Vector3 = Vector3.ZERO
var position2: Vector2 = Vector2.ZERO
var direction2: Vector2 = Vector2.ZERO
var normal: Vector3 = Vector3.ZERO
var angle: float = 0
var rotation: Quaternion
var power: float = 0
var index: int = 0
var text: String = ""
var source: Node
var target: Node
var enabled: bool = false
var targets: Array[Node] = []
var items: Array = []
var params: Dictionary = {}
var callback: Callable

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func start() -> bool:
	#dev.logd(TAG, "starting procedure %s" % name)
	if start_fx != null:
		world.spawn_fx(start_fx, position)
	
	if schedule_to_app_tasks:
		app.tasks.queue(self, self.name + "task-start", schedule_task_duration, null, start)
	else:
		if schedule_to_game_tasks:
			game.tasks.queue(self, self.name + "task-start", schedule_task_duration, null, start)
			
	return _start()

func _start() -> bool:
	dev.logd(TAG, "implement procedure start function, triggered: %s" % name)
	return true
