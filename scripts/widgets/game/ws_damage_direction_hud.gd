extends Control
class_name GDamageDirectionHUD 
const TAG: String = "DamageDirectionHUD"


class GDamageDirectionData:
	var direction: float = 0
	var power: float = 1
	var created_at: float = 0
	
	var age: float:
		get: 
			return tools.get_time() - created_at
	
	func _init(_dir: float, _power: float = 1):
		direction = _dir
		power = _power
		created_at = tools.get_time()
		
@export var show_time: float = 1
@export var color: Color = Color.RED
@export var thickness: float = 256
@export var center_to_edge: float = 0.9
@export var min_damage_arc_length: float = 1
@export var max_damage_arc_length: float = 10
@export var min_damage_opacity: float = 0.05
@export var max_damage_opacity: float = 0.05
@export var segments = 8
		
var hits: Array[GDamageDirectionData] = [
	GDamageDirectionData.new(0, 1),
	GDamageDirectionData.new(90, 0.5),
	GDamageDirectionData.new(180, 0.1)
]

var _min_registered_damage: float = 0
var _max_registered_damage: float = 1
var _time_gate: GTimeGateHelper = GTimeGateHelper.new(true)

func _process(delta):
	if _time_gate.check("update_hits_list", 1):
		_update_hits_list()
	
	if _time_gate.check("spawnd_test_direction", 1):
		for i in randi_range(2, 6):
			hits.append(GDamageDirectionData.new(randf_range(0, 360), randf_range(0.1, 1)))
			
	queue_redraw()

func _update_hits_list():
	var new_hits: Array[GDamageDirectionData] = []
	for item in hits:
		if item.age <= show_time:
			new_hits.append(item)
	hits = new_hits

func _draw():
	for item in hits:
		_draw_damage_direction(item)
	

func _draw_damage_direction(data: GDamageDirectionData):
	var parent_size = get_parent_area_size()
	var parent_min_size: float = min(parent_size.x, parent_size.y)
	var radius = lerpf(0, parent_min_size / 2, center_to_edge);
	var angle = data.direction
	var arc_length = lerpf(min_damage_arc_length, max_damage_arc_length, _get_damage_relative_power(data))
	var color: Color = color
	var opacity = lerpf(min_damage_opacity, max_damage_opacity, _get_damage_relative_power(data))
	opacity *= (1. - pow(_get_age_progress(data), 2.))
	color.a = opacity
	var antialias = true
	
	draw_arc(
		Vector2(parent_size.x / 2, parent_size.y / 2), 
		radius, 
		deg_to_rad(angle - arc_length / 2), 
		deg_to_rad(angle + arc_length / 2),
		segments, 
		color, 
		thickness, 
		antialias
	)
	
func _get_age_progress(data: GDamageDirectionData) -> float:
	return clampf(data.age / show_time, 0., 1.)
	
func _get_damage_relative_power(data: GDamageDirectionData) -> float:
	return tools.reverse_lerp(data.power, _min_registered_damage, _max_registered_damage)
	
