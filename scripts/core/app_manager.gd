# Author: @sanyabeast
# Date: Feb. 2024

extends Node
class_name RApp

const TAG: String = "App"
const SETTINGS_CONFIG_PATH: String = "user://settings.cfg"

const SETTINGS_KEY: String = "settings"

const SETTINGS_AUDIO_MASTER_VOLUME_KEY: String = "audio_settings__master_volume"
const SETTINGS_AUDIO_MUSIC_VOLUME_KEY: String = "audio_settings__music_volume"
const SETTINGS_AUDIO_SFX_VOLUME_KEY: String = "audio_settings__sfx_volume"

const SETTINGS_VIDEO_RENDER_SCALE: String = "video_settings__render_scale"
const SETTINGS_VIDEO_RENDER_SHARPNESS: String = "video_settings__render_sharpness"

@onready var data_index_path: String = ProjectSettings.get_setting("application/config/data_index")

var data: RDataIndex
var tasks: GTasker = GTasker.new(false)
var cooldowns: GCooldowns = GCooldowns.new(false)
var timer_gate: GTimeGateHelper = GTimeGateHelper.new(false)

# Create new ConfigFile object.
var settings_config = ConfigFile.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	var settings_config_err_code = settings_config.load(SETTINGS_CONFIG_PATH)
	if settings_config_err_code != 0:
		dev.logd(TAG, "settings_config config error: %s" % settings_config_err_code)
	
	data = load(data_index_path)
	dev.logd(TAG, "app  ready, data index resource loaded: %s" % data)
	dev.logd(TAG, "is debug: %s" % tools.IS_DEBUG)
	_load_settings()
	
	#AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(0))
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	tasks.update()
	pass

func quit():
	dev.logd(TAG, "quitting...")
	get_tree().quit()

# SETTINGS
func set_setting(key: String, value: Variant):
	tools.logd(TAG, "saving setting at %s, value: %s" % [key, value])
	settings_config.set_value(SETTINGS_KEY, key, value)
	settings_config.save(SETTINGS_CONFIG_PATH)

func get_setting(key: String, default: Variant = null):
	if not settings_config.has_section_key(SETTINGS_KEY, key):
		tools.logd(TAG, "settings item at %s does NOT exist: creating new with default value: %s" % [key, default])
		settings_config.set_value(SETTINGS_KEY, key, default)
		
	var result = settings_config.get_value(SETTINGS_KEY, key, default)
	tools.logd(TAG, "loaded setting at %s is %s" % [key, result])
	return result
# SOUND
func set_volume(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(clampf(value, 0, 1)))
	set_setting(SETTINGS_AUDIO_MASTER_VOLUME_KEY, value)
	
func set_music_volume(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(clampf(value, 0, 1)))
	set_setting(SETTINGS_AUDIO_MUSIC_VOLUME_KEY, value)

func set_sfx_volume(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(clampf(value, 0, 1)))
	set_setting(SETTINGS_AUDIO_SFX_VOLUME_KEY, value)
# getters
func get_volume()->float:
	return get_setting(SETTINGS_AUDIO_MASTER_VOLUME_KEY, 1)

func get_music_volume()->float:
	return get_setting(SETTINGS_AUDIO_MUSIC_VOLUME_KEY, 1)
	
func get_sfx_volume()->float:
	return get_setting(SETTINGS_AUDIO_SFX_VOLUME_KEY, 1)

func _load_settings():
	set_volume(get_setting(SETTINGS_AUDIO_MASTER_VOLUME_KEY, 1))
	set_music_volume(get_setting(SETTINGS_AUDIO_MUSIC_VOLUME_KEY, 1))
	set_sfx_volume(get_setting(SETTINGS_AUDIO_SFX_VOLUME_KEY, 1))
	
	set_render_scale(get_setting(SETTINGS_VIDEO_RENDER_SCALE, 1))
	set_render_sharpness(get_setting(SETTINGS_VIDEO_RENDER_SHARPNESS, 1))

# RENDERING
func set_render_scale(value: float):
	value = clampf(value, 0, 1)
	var viewport = get_viewport()
	viewport.scaling_3d_scale = value
	set_setting(SETTINGS_VIDEO_RENDER_SCALE, value)

func get_render_scale()->float:
	return get_setting(SETTINGS_VIDEO_RENDER_SCALE, 1)

# fsr sharpness
func set_render_sharpness(value: float):
	value = clampf(value, 0, 2)
	var viewport = get_viewport()
	viewport.fsr_sharpness = value
	set_setting(SETTINGS_VIDEO_RENDER_SHARPNESS, value)

func get_render_sharpness()->float:
	return get_setting(SETTINGS_VIDEO_RENDER_SHARPNESS, 1)
