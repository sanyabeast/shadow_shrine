
class_name S2MazeGenerator

# Enums
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

const TAG: String = "S2MazeGenerator: "

# MazeCell class
class Cell:
	var maze_generator: S2MazeGenerator
	var x: int
	var y: int
	var walls = {"north": true, "east": true, "south": true, "west": true}
	var category: ECellCategory
	var visited: bool = false
	var index: int
	var distance: int
	var route: int
	var neighbours_offsets = [{"x": -1, "y": 0}, {"x": 0, "y": -1}, {"x": 1, "y": 0}, {"x": 0, "y": 1}]

	func _init(_maze_generator: S2MazeGenerator, _x: int, _y: int, _category):
		maze_generator = _maze_generator
		x = _x
		y = _y
		category = _category if _category else ECellCategory.Default

	func get_walls_count():
		var result = 0
		if walls.north:
			result += 1
		if walls.east:
			result += 1
		if walls.south:
			result += 1
		if walls.west:
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
			walls.west = value
			cell2.walls.east = value
		elif x_diff == -1:
			walls.east = value
			cell2.walls.west = value

		if y_diff == 1:
			walls.north = value
			cell2.walls.south = value
		elif y_diff == -1:
			walls.south = value
			cell2.walls.north = value

	func get_wall_between(cell2):
		var x_diff = x - cell2.x
		var y_diff = y - cell2.y

		if x_diff == 1:
			return walls.west
		elif x_diff == -1:
			return walls.east

		if y_diff == 1:
			return walls.north
		elif y_diff == -1:
			return walls.south

	func get_neighbour_cell(offset):
		if offset < 0 or offset > 3:
			push_error("Offset must be between 0 and 3")
			return null

		var neighbour_x = x + neighbours_offsets[offset].x
		var neighbour_y = y + neighbours_offsets[offset].y

		if neighbour_x < 0 or neighbour_x >= maze_generator.grid_size or neighbour_y < 0 or neighbour_y >= maze_generator.grid_size:
			return null

		return maze_generator.cells[neighbour_x][neighbour_y]

# MazeGenerator class
var cells = []
var start_cell
var end_cell

var seed = 0
var grid_size = 4
var sparseness = 0.5
var dead_ends_ratio = 0.75
var shortcuts_ratio = 0.2
var generation_order = EGenerationOrder.Shift

var current_cell_index = 0
var routes = []

func _init():
	pass

func get_max_cells_count():
	return grid_size * grid_size

func get_random_cell():
	var x = randi() % grid_size
	var y = randi() % grid_size
	return cells[x][y]

func initialize():
	print(TAG + "initialize()")
	current_cell_index = 0
	cells.clear()
	routes.clear()

	for x in range(grid_size):
		cells.append([])
		for y in range(grid_size):
			cells[x].append(Cell.new(self, x, y, ECellCategory.Default))

func generate():
	initialize()

	var stack = []
	var current_cell = get_random_cell()
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

		if current_cell.index >= max(1, (1 - sparseness) * get_max_cells_count()):
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
			var random_index = randi() % unvisited_neighbours.size()
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
			cell.index = -1 if cell.index == null else cell.index

	# DEAD ENDS
	var dead_ends = find_cells_with_accessibility(ECellAccessibilityLevel.DeadEnd)
	for cell in dead_ends:
		if randf() > dead_ends_ratio:
			if cell.category in [ECellCategory.Start, ECellCategory.End]:
				continue

			var closed_neighbours = cell.get_closed_neighbours()
			if closed_neighbours.size() > 0:
				var random_index = randi() % closed_neighbours.size()
				var random_neighbour = closed_neighbours[random_index]

				cell.remove_wall_between(random_neighbour)
				cell.category = ECellCategory.Loop
				routes.append([cell, random_neighbour])

	# SHORTCUTS
	var transitive_cells = find_cells_with_accessibility(ECellAccessibilityLevel.Transitive)
	for cell in transitive_cells:
		var closed_neighbours = cell.get_closed_neighbours()
		if closed_neighbours.size() > 1:
			var random_index = randi() % closed_neighbours.size()
			var random_neighbour = closed_neighbours[random_index]
			if randf() < shortcuts_ratio:
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
