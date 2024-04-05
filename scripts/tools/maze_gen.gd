# Author: @sanyabeast
# Date: Feb. 2024

class_name GMazeGen
var TAG: String = "MazeGen"

#region: Enums
enum ECellCategory {
	Empty,
	Default,
	Shortcut,
	Loop,
	Start,
	End
}

enum ECellAccessibilityLevel {
	Crossroad,
	Fork,
	Transitive,
	DeadEnd,
	Isolated
}

enum EGenerationOrder {
	Pop,
	Shift
}
#endregion

#region: Cell
class Cell:
	var maze_generator: GMazeGen
	var x: int
	var y: int
	var walls = {
		world.EDirection.North: true, 
		world.EDirection.East: true, 
		world.EDirection.South: true, 
		world.EDirection.West: true
	}
	
	var category: ECellCategory
	var visited: bool = false
	var index: int = -1
	var distance: int
	var route: int
	var neighbours_offsets = [{"x": -1, "y": 0}, {"x": 0, "y": -1}, {"x": 1, "y": 0}, {"x": 0, "y": 1}]

	func _to_string():
		return "Cell(x: %s, y: %s, idx: %s, category: %s)" % [x, y, index, ECellCategory.keys()[category]]

	func _init(_maze_generator: GMazeGen, _x: int, _y: int, _category):
		maze_generator = _maze_generator
		x = _x
		y = _y
		category = _category if _category else ECellCategory.Default

	func get_walls_count():
		var result = 0
		if walls[world.EDirection.North]:
			result += 1
		if walls[world.EDirection.East]:
			result += 1
		if walls[world.EDirection.South]:
			result += 1
		if walls[world.EDirection.West]:
			result += 1
		return result

	func get_closed_neighbours():
		var result = []
		for cell in get_all_neighbours():
			if get_wall_between(cell) and cell.get_walls_count() != ECellAccessibilityLevel.Isolated:
				result.append(cell)
		return result

	func get_open_neighbours():
		var result = []
		for cell in get_all_neighbours():
			if not get_wall_between(cell):
				result.append(cell)
		return result

	func get_all_neighbours():
		var result = []
		for offset in neighbours_offsets:
			var neighbour = get_neighbour_cell(neighbours_offsets.find(offset))
			if neighbour != null:
				result.append(neighbour)
		return result

	func remove_wall_between(cell2):
		set_wall_between(cell2, false)

	func add_wall_between(cell2):
		set_wall_between(cell2, true)

	func set_wall_between(cell2, value):
		var x_diff = x - cell2.x
		var y_diff = y - cell2.y

		if x_diff == 1:
			walls[world.EDirection.West] = value
			cell2.walls[world.EDirection.East] = value
		elif x_diff == -1:
			walls[world.EDirection.East] = value
			cell2.walls[world.EDirection.West] = value

		if y_diff == 1:
			walls[world.EDirection.North] = value
			cell2.walls[world.EDirection.South] = value
		elif y_diff == -1:
			walls[world.EDirection.South] = value
			cell2.walls[world.EDirection.North] = value
			
	func get_sibling_to(direction: world.EDirection) -> Cell:
		var dx: int = 0
		var dy: int = 0
		
		match direction:
			world.EDirection.North:
				dy = -1
			world.EDirection.East:
				dx = +1
			world.EDirection.South:
				dy = +1
			world.EDirection.West:
				dx = -1
		
		if (x + dx) < 0 or (x + dx) >= maze_generator.config.size or (y + dy) < 0 or (y + dy) >= maze_generator.config.size:
			return null
			
				
		return maze_generator.cells[x + dx][y + dy]
		
	func get_wall_between(cell2):
		var x_diff = x - cell2.x
		var y_diff = y - cell2.y

		if x_diff == 1:
			return walls[world.EDirection.West]
		elif x_diff == -1:
			return walls[world.EDirection.East]

		if y_diff == 1:
			return walls[world.EDirection.North]
		elif y_diff == -1:
			return walls[world.EDirection.South]

	func get_neighbour_cell(offset):
		if offset < 0 or offset > 3:
			push_error("Offset must be between 0 and 3")
			return null

		var neighbour_x = x + neighbours_offsets[offset].x
		var neighbour_y = y + neighbours_offsets[offset].y

		if neighbour_x < 0 or neighbour_x >= maze_generator.config.size or neighbour_y < 0 or neighbour_y >= maze_generator.config.size:
			return null

		return maze_generator.cells[neighbour_x][neighbour_y]
#endregion
		
# MazeGenerator class
var cells = []
var cells_indexed = []
var start_cell: Cell
var end_cell: Cell

var seed: int = 0
var config: RMazeConfig = RMazeConfig.new()
var generation_order = EGenerationOrder.Shift

var current_cell_index: int = 0
var routes = []

var random: GRandHelper = GRandHelper.new()

func _init():
	pass

func set_config(_config: RMazeConfig):
	print(TAG + "config set to %s" % config)
	config = _config

func set_seed(_seed):
	random.set_seed(_seed)

func get_max_cells_count():
	return config.size * config.size

func get_cell(x: int, y: int):
	return cells[x][y]

func get_cell_with_index(index: int):
	return cells_indexed[index]

func get_random_cell():
	var x = random.randi() % config.size
	var y = random.randi() % config.size
	return cells[x][y]

func _prepare():
	print(TAG + "preparing...")
	current_cell_index = 0
	cells.clear()
	cells_indexed.clear()
	routes.clear()

	for x in range(config.size):
		cells.append([])
		for y in range(config.size):
			cells[x].append(Cell.new(self, x, y, ECellCategory.Default))
			cells_indexed.append(null)

func generate(_config):
	if _config is RMazeConfig:
		set_config(_config)
		
	_prepare()

	var stack = []
	#var current_cell = get_random_cell()
	var current_cell = get_cell(floor(config.size / 2), floor(config.size / 2))
	start_cell = current_cell
	var end_cell = current_cell
	current_cell.distance = 0
	current_cell.index = current_cell_index
	current_cell.visited = true
	current_cell.category = ECellCategory.Start
	stack.append(current_cell)

	var route = []

	while stack.size() > 0:
		route.append(current_cell)

		if current_cell.index >= max(1, (1 - config.sparseness) * get_max_cells_count()):
			if route.size() > 1:
				routes.append(route)
			route = []
			break

		var neighbours = current_cell.get_all_neighbours()
		var unvisited_neighbours = []
		for cell in neighbours:
			if not cell.visited:
				unvisited_neighbours.append(cell)

		if unvisited_neighbours.size() > 0:
			var random_index = random.randi() % unvisited_neighbours.size()
			var random_neighbour = unvisited_neighbours[random_index]
			current_cell.remove_wall_between(random_neighbour)
			random_neighbour.visited = true
			random_neighbour.distance = current_cell.distance + 1
			current_cell_index += 1
			random_neighbour.index = current_cell_index
			stack.append(random_neighbour)
			current_cell = random_neighbour
			if current_cell.distance > end_cell.distance:
				end_cell = current_cell
		else:
			if generation_order == EGenerationOrder.Pop:
				current_cell = stack.pop_back()
			elif generation_order == EGenerationOrder.Shift:
				current_cell = stack.pop_front()

			if route.size() > 1:
				routes.append(route)
			route = []

	end_cell.category = ECellCategory.End
	self.end_cell = end_cell

	for row in cells:
		for cell in row:
			if cell.index > -1:
				cells_indexed[cell.index] = cell

	# DEAD ENDS
	var dead_ends = find_cells_with_accessibility(ECellAccessibilityLevel.DeadEnd)
	for cell in dead_ends:
		if random.randf() > config.dead_ends:
			if cell.category in [ECellCategory.Start, ECellCategory.End]:
				continue

			var closed_neighbours = cell.get_closed_neighbours()
			if closed_neighbours.size() > 0:
				var random_index = random.randi() % closed_neighbours.size()
				var random_neighbour = closed_neighbours[random_index]

				cell.remove_wall_between(random_neighbour)
				cell.category = ECellCategory.Loop
				routes.append([cell, random_neighbour])

	# SHORTCUTS
	var transitive_cells = find_cells_with_accessibility(ECellAccessibilityLevel.Transitive)
	for cell in transitive_cells:
		var closed_neighbours = cell.get_closed_neighbours()
		if closed_neighbours.size() > 1:
			var random_index = random.randi() % closed_neighbours.size()
			var random_neighbour = closed_neighbours[random_index]
			if random.randf() < config.shortcuts:
				cell.remove_wall_between(random_neighbour)
				cell.category = ECellCategory.Shortcut
				routes.append([cell, random_neighbour])

	for row in cells:
		for cell in row:
			cell.category = ECellCategory.Empty if cell.get_walls_count() == ECellAccessibilityLevel.Isolated else cell.category

	reset_visited()

	# ... The rest of the methods, including for_each_cell and reset
func find_cells_with_accessibility(level):
	var result = []
	for row in cells:
		for cell in row:
			if cell.get_walls_count() == level:
				result.append(cell)
	return result	
	
func reset_visited():
	for row in cells:
		for cell in row:
			cell.visited = false
			
func get_cell_category_pretty_name(cat: ECellCategory)->String:
	match cat:
		ECellCategory.Empty:
			return "Empty"
		ECellCategory.Default:
			return "Default"
		ECellCategory.Shortcut:
			return "Shortcut"
		ECellCategory.Loop:
			return "Loop"
		ECellCategory.Start:
			return "Start"
		ECellCategory.End:
			return "End"
	return "?"
