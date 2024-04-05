extends Control
class_name GHighlightsWidget
var TAG: String = "HighlightsWidget"
	
@export_subgroup("# Highlights Widget")
@onready var label: GWidgetLabel = $Label
@export var messages: Array[RHighlightsMessage] = []

@export_subgroup("# Highlights Widget ~ Referencies")
@export var anim_player: AnimationPlayer
@export var title_label: GWidgetLabel
@export var subtitle_label: GWidgetLabel

var is_showing: bool = false
var current_message: RHighlightsMessage
var cooldowns: GCooldowns = GCooldowns.new(true)

# Called when the node enters the scene tree for the first time.
func _ready():
	anim_player.play("RESET")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_showing:
		if cooldowns.ready("show-timeout"):
			_hide_message()
	else:
		if cooldowns.ready("next-message", true):
			if messages.size() > 0:
				_show_message(messages.pop_front())

func _show_message(data: RHighlightsMessage):
	is_showing = true
	current_message = data
	
	cooldowns.start("show-timeout", data.duration)
	delay(data.duration)
	
	title_label.set_content(data.title)
	subtitle_label.set_content(data.subtitle)
	anim_player.play("show")
	
func show_message(title: String = "", subtitle: String = "", duration: float = 5):
	messages.append(RHighlightsMessage.new(title, subtitle, duration))

func _hide_message():
	anim_player.play("hide")

func _handle_animation_started(name: String):
	var data = current_message
	match name:
		"hide":
			if data != null:
				pass

func delay(timeout: float):
	cooldowns.start("next-message", timeout)

func _handle_animation_finished(name: String):
	var data = current_message
	match name:
		"show":
			cooldowns.start("show-timeout", data.duration)
		"hide":
			is_showing = false
	pass
