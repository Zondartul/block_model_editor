extends ShapeGenerator
class_name ShapeGenBox

var _params = {"x":1.0, "y":1.0, "z":1.0};
var _col_shape;

# returns an array of {name,type,range} params
func get_param_list() -> Array:
	return [{"name":"x", "type":"float", "range":null},\
			{"name":"y", "type":"float", "range":null},\
			{"name":"z", "type":"float", "range":null}];

# returns the value of a parameter
func get_param(param_name:String) -> Variant:
	return _params[param_name];

func set_param(param_name:String, val:Variant) -> void:
	_params[param_name] = val;
	update_shapes();

func gen_shapes()->void:
	if _n_vis_shape: _n_vis_shape.queue_free()
	if _n_collider: _n_collider.queue_free()
	_n_vis_shape = CSGBox3D.new()
	_col_shape = BoxShape3D.new()
	_n_vis_shape.material = StandardMaterial3D.new()
	_n_collider = CollisionShape3D.new();
	_n_collider.shape = _col_shape;
	update_shapes();

func update_shapes()->void:
	_n_vis_shape.size = Vector3(_params.x, _params.y, _params.z);
	_col_shape.size = Vector3(_params.x, _params.y, _params.z);
