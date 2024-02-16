extends S2GameMode

class_name S2GameModeDefaultGame 


var environment_node: Node3D
var architecture_node: Node3D
var characters_node: Node3D
var collectibles_node: Node3D

var maze_generator: S2MazeGenerator = S2MazeGenerator.new()
var current_maze_cell: S2MazeGenerator.Cell = null


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	pass # Replace with function body.

func prepare():
	environment_node = $Environment
	architecture_node = $Architecture
	characters_node = $Characters
	collectibles_node = $Collectibles
	
	assert(environment_node != null, "$Environment node not found")
	assert(architecture_node != null, "$Architecture node not found")
	assert(characters_node != null, "$Characters node not found")
	assert(collectibles_node != null, "$Collectibles node not found")
	
	
	maze_generator.grid_size = 4
	maze_generator.sparseness = 0.1
	maze_generator.dead_ends_ratio = 0.8
	maze_generator.shortcuts_ratio = 0.1
	maze_generator.generate()
	
	current_maze_cell = maze_generator.start_cell
	print(maze_generator.start_cell)
	
	super.prepare()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


