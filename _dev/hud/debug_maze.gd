extends Control  # Or any other GUI node

class_name S2MazeDebugPainter

var cell_size: Vector2 = Vector2(10, 10)  # Size of each cell in pixels

func _ready():
	dev.set_maze_painter(self)
	pass

func _draw():
	if game.game_mode is S2GameModeDefaultGame and game.game_mode.maze_generator:
		for row in game.game_mode.maze_generator.cells:
			for cell in row:
				draw_cell(cell)
		
func _process(delta):
	if game.game_mode is S2GameModeDefaultGame and game.game_mode.maze_generator:
		cell_size =  Vector2(100 / game.game_mode.maze_generator.grid_size, 100 / game.game_mode.maze_generator.grid_size)
		queue_redraw()
	
func draw_cell(cell: S2MazeGenerator.Cell):
	if game.game_mode is S2GameModeDefaultGame and game.game_mode.maze_generator:
		if cell.category == S2MazeGenerator.ECellCategory.Empty:
			return
		
		var cell_pos = Vector2(cell.x * cell_size.x, cell.y * cell_size.y)
		cell_size = Vector2(100 / game.game_mode.maze_generator.grid_size, 100 / game.game_mode.maze_generator.grid_size)  # Size of each cell in pixels

		# Draw walls as lines
		if cell.walls[world.EDirection.North]:
			draw_line(cell_pos, cell_pos + Vector2(cell_size.x, 0), Color(1, 1, 1))
		if cell.walls[world.EDirection.East]:
			draw_line(cell_pos + Vector2(cell_size.x, 0), cell_pos + cell_size, Color(1, 1, 1))
		if cell.walls[world.EDirection.South]:
			draw_line(cell_pos + cell_size, cell_pos + Vector2(0, cell_size.y), Color(1, 1, 1))
		if cell.walls[world.EDirection.West]:
			draw_line(cell_pos + Vector2(0, cell_size.y), cell_pos, Color(1, 1, 1))
		
		if cell.category == S2MazeGenerator.ECellCategory.Start:
			var rect = Rect2(cell_pos, Vector2(cell_size.x, cell_size.x))	
			draw_rect(rect, Color(0, 1, 0), true)	
			
		if cell.category == S2MazeGenerator.ECellCategory.End:
			var rect = Rect2(cell_pos, Vector2(cell_size.x, cell_size.x))	
			draw_rect(rect, Color(1, 0, 0), true)		
			
		if game.game_mode.current_maze_cell.x == cell.x and game.game_mode.current_maze_cell.y == cell.y:
			var rect = Rect2(cell_pos, Vector2(cell_size.x, cell_size.x))	
			draw_rect(rect, Color(0,0,1), true)	
			
	
	
