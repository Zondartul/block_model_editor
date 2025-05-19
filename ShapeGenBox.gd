extends ShapeGenerator
class_name ShapeGenBox

var params = {"x":1.0, "y":1.0, "z":1.0};

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
	gen_shapes();

func gen_shapes()->void:
	var col_shape;
	n_vis_shape = CSGBox3D.new()
	col_shape = BoxShape3D.new()
	n_vis_shape.material = StandardMaterial3D.new()
	n_collider = CollisionShape3D.new();
	n_collider.shape = col_shape;
