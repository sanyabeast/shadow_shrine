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
	if not game.paused:
		_update_npcs(delta)

func _update_npcs(delta):
	for character in list:
		if not player.is_player(character):
			_update_single_npc(character, delta)
	
func _update_single_npc(character: S2Character, delta):
	character.npc_controller.update(delta)
	pass		
			
