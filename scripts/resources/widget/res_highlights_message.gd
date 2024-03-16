# highlight message class
extends Resource
class_name RHighlightsMessage

const DEFAULT_TITLE_DURATION: float = 5
	
@export var title: String = ""
@export var subtitle: String = ""
@export var duration: float = DEFAULT_TITLE_DURATION

var has_subtitle: bool = false

func _init(_title: String = "", _subtitle: String = "", _duration: float = DEFAULT_TITLE_DURATION):
	title = _title
	subtitle = _subtitle
	duration = _duration
	has_subtitle = subtitle.length() > 0
