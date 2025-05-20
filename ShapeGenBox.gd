extends ShapeGenerator
class_name ShapeGenBox

var params = {"x":1.0, "y":1.0, "z":1.0};
var col_shape;

# returns an array of {name,type,range} params
func get_param_list() -> Array:
	return [{"name":"x", "type":"float", "range":null},\
			{"name":"y", "type":"float", "range":null},\
			{"name":"z", "type":"float", "range":null}];

# returns the value of a parameter
func get_param(name:String) -> Variant:
	return params[name];

func set_param(name:String, val:Variant) -> void:
	params[name] = val;
	update_shapes();

func gen_shapes()->void:
	if n_vis_shape: n_vis_shape.queue_free()
	if n_collider: n_collider.queue_free()
	n_vis_shape = CSGBox3D.new()
	n_vis_shape.size = Vector3(params.x, params.y, params.z);
	col_shape = BoxShape3D.new()
	col_shape.size = Vector3(params.x, params.y, params.z);
	n_vis_shape.material = StandardMaterial3D.new()
	n_collider = CollisionShape3D.new();
	n_collider.shape = col_shape;

func update_shapes()->void:
	n_vis_shape.size = Vector3(params.x, params.y, params.z);
	col_shape.size = Vector3(params.x, params.y, params.z);
