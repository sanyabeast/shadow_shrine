# Author: @sanyabeast
# Date: Jan. 2024

@icon("res://assets/_dev/_icons/35d.png")
extends Control

class_name GDevLabels

var _containers: Dictionary = {}
var _targets: Dictionary = {}
var _labels: Dictionary = {}
var _lines: Dictionary = {}
# Called when the node enters the scene tree for the first time.
func _ready():
	dev.set_debug_labels(self)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if visible:
		_update_labels()
	pass

func set_label(target: Node3D, lines: Dictionary):
	var label_id: String = target.name
	var container: VBoxContainer
	if label_id in _containers:
		container = _containers[label_id]
		pass
	else:
		container = VBoxContainer.new()
		container.anchors_preset
		_containers[label_id] = container
		_labels[label_id] = {}
		_targets[label_id] = target
		add_child(container)
		
	for i in lines.keys().size():
		var line_id = lines.keys()[i]
		var text = lines[line_id]
		var label: Label
		
		if line_id in _labels[label_id]:
			label = _labels[label_id][line_id]
		else:
			label = Label.new()
			label.add_theme_font_size_override("font_size", 8)
			label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
			_labels[label_id][line_id] = label
			container.add_child(label)
		
		label.text = text
		
	_lines[label_id] = lines	
		
	_update_labels()

func _update_labels():
	var camera3d: Camera3D = camera_manager.get_camera3d()
	
	if camera3d != null:
		for label_id in _containers.keys():
			if _targets[label_id] == null or not _targets[label_id].is_inside_tree():
				_erase_label(label_id)
				return
				
			var target: Node3D = _targets[label_id]
			var container: VBoxContainer = _containers[label_id]
			var distance: float = target.global_position.distance_to(camera3d.global_position)
			
			container.visible = true
			var screen_pos: Vector2 = camera3d.unproject_position(target.global_transform.origin)
			container.position = screen_pos
			
			for line_id in _labels[label_id].keys():
				var label: Label = _labels[label_id][line_id]
				label.text = _lines[label_id][line_id]
		pass
		

func remove_label(target: Node3D):
	var label_id: String = target.name
	_erase_label(label_id)
	pass

func _erase_label(label_id: String):
	if label_id in _containers:
		remove_child(_containers[label_id])
		_containers[label_id].queue_free()
		for key in _labels[label_id]:
			var label = _labels[label_id][key]
			label.queue_free()
		
	_containers.erase(label_id)
	_targets.erase(label_id)
	_labels.erase(label_id)
