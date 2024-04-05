extends GFreeroamMode

@export var max_enemies: float = 10
@export var enemies: Array[String] = []

var _time_gate:= GTimeGateHelper.new(true)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _time_gate.check("fill-enemies", 1) and characters.alive_enemies_count < max_enemies:
		_spawn_enemy()

func on_start():
	game.resume()
	characters.enable_player()
	#characters.enable_ai()

func handle_player_dead():
	var spawn_position = world.get_random_reachable_point_in_square(characters.last_player_position, 16, 8)
	if spawn_position == null:
		spawn_position = Vector3.ZERO
	characters.respawn_player(spawn_position)
	pass

func _spawn_enemy():
	var spawn_position = world.get_random_reachable_point_in_square(characters.last_player_position, 32, 16)
	
	if spawn_position != null:
		var entry = game.thesaurus.get_one_item_from_list_by_rarity("characters", enemies, game.difficulty)
		var enemy = characters.spawn_character(world.get_scene(), entry.id, spawn_position)
	else:
		dev.logd(TAG, "enemy spawn skipped as there was no spawn point found for it")
	
	
