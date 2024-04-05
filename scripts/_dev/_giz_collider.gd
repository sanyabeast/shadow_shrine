extends GGizmo

# Called when the node enters the scene tree for the first time.
func _ready():
	if tools.IS_DEBUG:
		_setup()
		
func _setup():
	var parent = get_parent()
	var _self = self
	assert(_self is MeshInstance3D, "GColliderGizmo script should be attached to MeshInstance3D node. found %s " % _self)
	assert(parent is CollisionObject3D, "GColliderGizmo should be added as child to CollisionShape3D object. found: %s" % parent)
	
	var collider: CollisionShape3D = parent
	var mesh_instance: MeshInstance3D = _self
	
	var mesh: ArrayMesh = collider.shape.get_debug_mesh()
	
	mesh_instance.mesh = mesh
	
	
	
