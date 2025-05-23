extends ShapeGenerator
class_name ShapeGenSphere

var params = {"r":1.0, "sides_x":12, "sides_y":16, "smooth":true};
var col_shape;

# returns an array of {name,type,range} params
func get_param_list() -> Array:
	return [{"name":"r", "type":"float", "range":null},\
			{"name":"sides_x", "type":"int", "range":[4,64]},\
			{"name":"sides_y", "type":"int", "range":[4,64]},\
			{"name":"smooth", "type":"bool", "range":null}]
			
# returns the value of a parameter
func get_param(param_name:String) -> Variant:
	return params[param_name];

func set_param(param_name:String, val:Variant) -> void:
	params[param_name] = val;
	update_shapes();

func gen_shapes()->void:
	if n_vis_shape: n_vis_shape.queue_free()
	if n_collider: n_collider.queue_free()
	n_vis_shape = CSGSphere3D.new()
	col_shape = SphereShape3D.new()
	n_vis_shape.material = StandardMaterial3D.new()
	n_collider = CollisionShape3D.new();
	n_collider.shape = col_shape;
	update_shapes();

func update_shapes()->void:
	n_vis_shape.radius = params.r;
	n_vis_shape.radial_segments = params.sides_x;
	n_vis_shape.rings = params.sides_y;
	n_vis_shape.smooth_faces = params.smooth;
	col_shape.radius = params.r;
