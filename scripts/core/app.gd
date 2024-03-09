# Author: @sanyabeast
# Date: Feb. 2024

extends Node

class_name RApp

const TAG: String = "App"
const SETTINGS_CONFIG_PATH: String = "user://settings.cfg"

@onready var data_index_path: String = ProjectSettings.get_setting("application/config/data_index")

var data: RDataIndex
var tasks: S2TaskPlanner = S2TaskPlanner.new(false)
var cooldowns: S2CooldownManager = S2CooldownManager.new(false)
var timer_gate: S2TimerGateManager = S2TimerGateManager.new(false)

# Create new ConfigFile object.
var settings_config = ConfigFile.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	var settings_config_err_code = settings_config.load(SETTINGS_CONFIG_PATH)
	if settings_config_err_code != 0:
		dev.logd(TAG, "settings_config config error: %s" % settings_config_err_code)
	
	data = load(data_index_path)
	set_music_volume(0)
	dev.logd(TAG, "app  ready, data index resource loaded: %s" % data)
	dev.logd(TAG, "is debug: %s" % tools.IS_DEBUG)
		
	#AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(0))
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func quit():
	dev.logd(TAG, "quitting...")
	get_tree().quit()

# SETTINGS
func set_setting(section: String, key: String, value: Variant):
	settings_config.set_value(section, key, value)
	settings_config.save(SETTINGS_CONFIG_PATH)

func get_setting(section: String, key: String, default: Variant = null):
	return settings_config.get_value(section, key, default)

# SOUND
func set_volume(value: float):
	set_setting("sound", "master_volume", value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(clampf(value, 0, 1)))
	
func set_music_volume(value: float):
	set_setting("sound", "music_volume", value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(clampf(value, 0, 1)))

func set_sfx_volume(value: float):
	set_setting("sound", "sfx_volume", value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(clampf(value, 0, 1)))
# getters
func get_volume()->float:
	return AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))

func get_music_volume()->float:
	return AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
	
func get_sfx_volume()->float:
	return AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))
