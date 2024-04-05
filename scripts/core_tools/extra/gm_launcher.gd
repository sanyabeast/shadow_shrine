extends GGameMode
class_name GLauncherMode
var TAG: String = "LauncherMode"

func _ready():
	dev.logd(TAG, "ready")
	if tools.IS_DEBUG:
		app.load_debug_level()
		pass
	else:
		app.load_main_menu_level()
