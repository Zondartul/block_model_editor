extends ShapeGenerator
class_name ShapeGenCylinder

var params = {"r":1.0, "h":1.0, "sides":16.0, "cone":false};
var col_shape;

# returns an array of {name,type,range} params
func get_param_list() -> Array:
	return [{"name":"r", "type":"float", "range":null},\
			{"name":"h", "type":"float", "range":null},\
			{"name":"sides", "type":"int", "range":[3,64]},\
			{"name":"cone", "type":"bool", "range":null}]
			
# returns the value of a parameter
func get_param(name:String) -> Variant:
	return params[name];

func set_param(name:String, val:Variant) -> void:
	params[name] = val;
	update_shapes();

func gen_shapes()->void:
	if n_vis_shape: n_vis_shape.queue_free()
	if n_collider: n_collider.queue_free()
	n_vis_shape = CSGCylinder3D.new()
	#n_vis_shape.height = params.h;
	#n_vis_shape.radius = params.r;
	#n_vis_shape.sides = params.sides;
	#n_vis_shape.cone = params.cone;
	col_shape = CylinderShape3D.new()
	#col_shape.height = params.h;
	#col_shape.radius = params.r;
	n_vis_shape.material = StandardMaterial3D.new()
	n_collider = CollisionShape3D.new();
	n_collider.shape = col_shape;
	update_shapes();

func update_shapes()->void:
	n_vis_shape.height = params.h;
	n_vis_shape.radius = params.r;
	n_vis_shape.sides = params.sides;
	n_vis_shape.cone = params.cone;
	col_shape.height = params.h;
	col_shape.radius = params.r;
