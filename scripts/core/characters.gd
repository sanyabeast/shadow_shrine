extends Node

class_name S2CharactersManager

var list: Array[S2Character]

# Called when the node enters the scene tree for the first time.
func _ready():
	print("characters manager: ready...")
	pass # Replace with function body.

func register(character: S2Character):
	list.append(character)
	pass
	
func discharge(character: S2Character):
	var index = list.find(character)
	if index > -1:
		list.remove_at(index)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	dev.print_screen("total_characters", "active characters: %s" % list.size())
	
	_update_npcs(delta)

func _update_npcs(delta):
	for character in list:
		if not player.is_player(character):
			_update_single_npc(character, delta)
	
func _update_single_npc(npc: S2Character, delta):
	npc.walk_power = 1
	var move_direction = Vector3.ZERO
	
	if player.current != null:
		move_direction = npc.global_position.direction_to(player.current.global_position)
	else:
		npc.walk_power = 0
	npc.walk_direction = move_direction
	
	pass		
			
