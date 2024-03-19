
extends RSurfaceState

class_name RRimSurfaceState 

@export var id: String

@export var process_overlay_material: bool = true
@export var overlay_albedo: Color = Color.WHITE
@export var overlay_thickness: float = 0.25
@export var overlay_brightness: float = 1


func update_shader_parameters():
	shader_parameters = {
		"albedo": overlay_albedo,
	 	"rimThickness": overlay_thickness,
 		"rimBrightness": overlay_brightness
	}
