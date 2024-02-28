
class_name S2TaskPlanner

static var _schedule_task_index_counter: int = 0

class Task:
	var owner: Node3D
	var id: String
	var duration: float
	var start_callback
	var finish_callback
	var started_at: float = -1
	var use_game_time: bool = false
	
	func _init(_owner: Node3D, _id: String, _duration: float, _start_callback, _finish_callback, _use_game_time):
		owner = _owner
		id = _id
		duration = _duration
		start_callback = _start_callback
		finish_callback = _finish_callback
		use_game_time = _use_game_time
	func is_expired()->bool:
		if started_at < 0:
			return false
		else:
			return (get_time() - started_at) > duration
	func start():
		started_at = get_time()
		
		if start_callback != null:
			start_callback.call()
	func finish():
		if finish_callback != null:
			finish_callback.call()
	
	func is_valid()->bool:
		return owner != null
		
	func get_time() -> float:
		if use_game_time:
			return game.get_time()
		else:
			return tools.get_time()	

# TaskPlanner props
var list: Array[Task] = []
var schedule_list = {}
var current: Task
var use_game_time: bool = false

func _init(_use_game_time: bool):
	use_game_time = _use_game_time

# TaskPlanner methods
func update():
	if current == null:
		if list.size() > 0:
			current = list.pop_back()
			if current.is_valid():
				print("[TaskPlanner] task STARTED %s %s" % [current.owner.name, current.id])
				current.start()
			else:
				current = null
	else:
		if current.is_expired():
			if current.is_valid():
				print("[TaskPlanner] task FINISHED %s %s" % [current.owner.name, current.id])
				current.finish()
				
			current = null	
			
	for key in schedule_list.keys():
		var task: Task = schedule_list[key]
		if task.is_expired():
			if task.is_valid():
				print("[TaskPlanner] scheduled task FINISHED %s %s" % [task.owner.name, task.id])
				task.finish()
			schedule_list.erase(key)
			
func queue(owner: Node3D, id: String, duration: float, start_callback, finish_callback):
	list.push_front(S2TaskPlanner.Task.new(
		owner,
		id,
		duration,
		start_callback,
		finish_callback,
		use_game_time
	))
	print("[TaskPlanner] task ADDED to queue %s %s" % [owner.name, id])
	pass

func stack(owner: Node3D, id: String, duration: float, start_callback, finish_callback):
	list.push_back(S2TaskPlanner.Task.new(
		owner,
		id,
		duration,
		start_callback,
		finish_callback,
		use_game_time
	))
	print("[TaskPlanner] task ADDED to stack %s %s" % [owner.name, id])
	pass
	
func schedule(owner: Node3D, id: String, timeout: float, finish_callback):
	var task: Task = Task.new(owner, id, timeout, null, finish_callback, use_game_time)
	S2TaskPlanner._schedule_task_index_counter += 1	
	schedule_list[S2TaskPlanner._schedule_task_index_counter] = task
	task.start()
	
func stack_replace(owner: Node3D, id: String, duration: float, start_callback, finish_callback):
	cancel(owner, id)
	stack(owner, id, duration, start_callback, finish_callback)

func queue_replace(owner: Node3D, id: String, duration: float, start_callback, finish_callback):
	cancel(owner, id)
	queue(owner, id, duration, start_callback, finish_callback)

func schedule_replace(owner: Node3D, id: String, timeout: float, finish_callback):
	cancel(owner, id)
	schedule(owner, id, timeout, finish_callback)

func cancel(owner: Node3D, id):
	if current != null and current.owner == owner:
		if id == null or id == current.id:
			current = null
	
	var new_list: Array[Task] = []
	
	for task in list:
		if task.owner != owner:
			if id != null or id != task.id:
				new_list.append(task)
	
	for key in schedule_list.keys():
		var task: Task = schedule_list[key]
		if task.owner == owner:
			if id == null or id == task.id:
				schedule_list.erase(key)
	
	list = new_list

func clear(finish_current: bool = true):
	list = []
	
	if finish_current and current != null:
		current.finish()
		
	current = null
