extends Node
class_name GProcedure
const TAG: String = "Procedure"

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
var source: Node3D
var target: Node3D
var enabled: bool = false
var targets: Array[Node3D] = []
var items: Array = []
var params: Dictionary = {}
var callback: Callable

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func start():
	dev.logd(TAG, "starting task %s" % name)
	if start_fx != null:
		world.spawn_fx(start_fx, position)
	
	if schedule_to_app_tasks:
		app.tasks.schedule(self, self.name + "task-start", schedule_task_duration, start)
	else:
		if schedule_to_game_tasks:
			game.tasks.schedule(self, self.name + "task-start", schedule_task_duration, start)
			
	_start()
	pass

func _start():
	dev.logd(TAG, "implement procedure start function")
