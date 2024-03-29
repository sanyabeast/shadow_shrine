# Author: @sanyabeast
# Date: Feb. 2024

extends Node

class_name GAppManager
const TAG: String = "AppManager"

enum EGraphicsQualityPreset {
	Medium,
	Standard,
	High,
	Ultra
}

const SETTINGS_CONFIG_PATH:= "user://settings.cfg"

const SETTINGS_KEY:= "settings"
const SETTINGS_AUDIO_MASTER_VOLUME_KEY:= "audio_settings__master_volume"
const SETTINGS_AUDIO_MUSIC_VOLUME_KEY:= "audio_settings__music_volume"
const SETTINGS_AUDIO_SFX_VOLUME_KEY:= "audio_settings__sfx_volume"

const SETTINGS_VIDEO_PRESET:= "video_settings__preset"
const SETTINGS_VIDEO_RENDER_SCALE:= "video_settings__render_scale"
const SETTINGS_VIDEO_RENDER_SHARPNESS:= "video_settings__render_sharpness"
const SETTINGS_VIDEO_VBLANK_MODE:= "video_settings__vblank_mode"

signal on_graphics_quality_preset_changed

@onready var data_index_path: String = ProjectSettings.get_setting("application/config/data_index")

var data: RDataIndex
var tasks: GTasker = GTasker.new(false)
var cooldowns: GCooldowns = GCooldowns.new(false)
var timer_gate: GTimeGateHelper = GTimeGateHelper.new(false)

var graphics_quality: EGraphicsQualityPreset = EGraphicsQualityPreset.Ultra

# Create new ConfigFile object.
var settings_config = ConfigFile.new()

#region: Lifecycle
func _ready():
	var settings_config_err_code = settings_config.load(SETTINGS_CONFIG_PATH)
	if settings_config_err_code != 0:
		dev.logd(TAG, "settings_config config error: %s" % settings_config_err_code)
	
	data = load(data_index_path)
	dev.logd(TAG, "app  ready, data index resource loaded: %s" % data)
	dev.logd(TAG, "is debug: %s" % tools.IS_DEBUG)
	_load_settings()
	
	pass # Replace with function body.

func _process(delta):
	tasks.update()
	
	if Input.is_action_just_pressed("toggle_fullscreen"):
		set_fullscreen(not get_fullscreen())
		
	if tools.IS_DEBUG:
		if Input.is_action_just_pressed("_dev_load_main_menu"):
			app.load_main_menu_level()
		if Input.is_action_just_pressed("_dev_load_game_level"):
			app.load_default_game_level()
		if Input.is_action_just_pressed("_dev_load_debug_level"):
			app.load_debug_level()	
		if Input.is_action_just_pressed("_dev_reload_level"):
			app.reload_level()
	
func quit():
	dev.logd(TAG, "quitting...")
	get_tree().quit()
#endregion

#region: Settings management
func set_setting(key: String, value: Variant):
	#tools.logd(TAG, "saving setting at %s, value: %s" % [key, value])
	settings_config.set_value(SETTINGS_KEY, key, value)
	settings_config.save(SETTINGS_CONFIG_PATH)

func get_setting(key: String, default: Variant = null):
	if not settings_config.has_section_key(SETTINGS_KEY, key):
		tools.logd(TAG, "settings item at %s does NOT exist: creating new with default value: %s" % [key, default])
		settings_config.set_value(SETTINGS_KEY, key, default)
		
	var result = settings_config.get_value(SETTINGS_KEY, key, default)
	#tools.logd(TAG, "loaded setting at %s is %s" % [key, result])
	return result

func _load_settings():
	set_volume(get_setting(SETTINGS_AUDIO_MASTER_VOLUME_KEY, 1))
	set_music_volume(get_setting(SETTINGS_AUDIO_MUSIC_VOLUME_KEY, 0.5))
	set_sfx_volume(get_setting(SETTINGS_AUDIO_SFX_VOLUME_KEY, 1))
	
	set_render_scale(get_setting(SETTINGS_VIDEO_RENDER_SCALE, 1))
	set_render_sharpness(get_setting(SETTINGS_VIDEO_RENDER_SHARPNESS, 1))
	set_vnlank_mode(get_setting(SETTINGS_VIDEO_VBLANK_MODE, DisplayServer.VSYNC_ENABLED))
	
	set_graphics_quality(get_setting(SETTINGS_VIDEO_PRESET, EGraphicsQualityPreset.High))
#endregion

#region: Levels

func reload_level():
	load_level(get_tree().current_scene.scene_file_path)
	#tools.reload_scene()
	
func load_level(level_path: String):
	dev.logd(TAG, "loading (deffered) level: %s" % level_path)
	var tree: SceneTree = get_tree()
	if tree.current_scene == null:
		_load_level(level_path)
	else:
		#_load_level(level_path)
		call_deferred("_load_level", level_path)

func _load_level(level_path: String):
	dev.logd(TAG, "loading level: %s" % level_path)
	var tree: SceneTree = get_tree()
	tree.unload_current_scene()
	tree.change_scene_to_file(level_path)

func load_main_menu_level():
	load_level(ProjectSettings.get_setting("game/meta/main_menu_level_path"))
	
func load_default_game_level():
	load_level(ProjectSettings.get_setting("game/meta/default_game_level_path"))
	
func load_debug_level():
	load_level(ProjectSettings.get_setting("game/meta/default_debug_level_path"))
#endregion

#region: Sound management
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
#endregion

#region: Remndering and Graphics settings
func set_render_scale(value: float):
	value = clampf(value, 0, 1)
	var viewport = get_viewport()
	viewport.scaling_3d_scale = value
	set_setting(SETTINGS_VIDEO_RENDER_SCALE, value)

func get_render_scale()->float:
	return get_setting(SETTINGS_VIDEO_RENDER_SCALE, 1)

func set_render_sharpness(value: float):
	value = clampf(value, 0, 2)
	var viewport = get_viewport()
	viewport.fsr_sharpness = value
	set_setting(SETTINGS_VIDEO_RENDER_SHARPNESS, value)

func get_render_sharpness()->float:
	return get_setting(SETTINGS_VIDEO_RENDER_SHARPNESS, 1)

func set_graphics_quality(preset: EGraphicsQualityPreset):
	graphics_quality = preset
	set_setting(SETTINGS_VIDEO_PRESET, preset)
	on_graphics_quality_preset_changed.emit()
	_update_quality_preset_settings()

func set_vnlank_mode(mode: DisplayServer.VSyncMode):
	DisplayServer.window_set_vsync_mode(mode)
	set_setting(SETTINGS_VIDEO_VBLANK_MODE, mode)
	pass
	
func get_vblank_mode() -> DisplayServer.VSyncMode:
	return DisplayServer.window_get_vsync_mode()

func get_graphics_quality() -> EGraphicsQualityPreset:
	return graphics_quality

func set_fullscreen(enabled: bool):
	if enabled == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	if enabled == false:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func get_fullscreen() -> bool:
	return DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN

func _update_quality_preset_settings():
	pass
#endregion
