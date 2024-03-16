extends Control
class_name GHighlightsWidget
const TAG: String = "HighlightsWidget"

# highlight message class
class RHighlihghMessage:
	@export var title: String = "?"
	@export var subtitle: String = "?"
	@export var duration: float = 3.
	
	var has_subtitle: bool = false
	
	func _init(_title: String = "?", _subtitle: String = "?", _duration: float = 3):
		title = _title
		subtitle = _subtitle
		duration = _duration
		
		has_subtitle = subtitle.length() > 0
		
		
@onready var label: GWidgetLabel = $Label
@export var messages: Array[String] = []
@export var duration: float = 2
@export var duration_with_subtitle: float = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
