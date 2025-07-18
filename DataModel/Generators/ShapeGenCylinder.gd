extends ShapeGenerator
class_name ShapeGenCylinder

var _params = {"r":1.0, "h":1.0, "sides":16.0, "cone":false};
var _col_shape;

# returns an array of {name,type,range} params
func get_param_list() -> Array:
	return [{"name":"r", "type":"float", "range":null},\
			{"name":"h", "type":"float", "range":null},\
			{"name":"sides", "type":"int", "range":[3,64]},\
			{"name":"cone", "type":"bool", "range":null}]
			
# returns the value of a parameter
func get_param(param_name:String) -> Variant:
	return _params[param_name];

func set_param(param_name:String, val:Variant) -> void:
	_params[param_name] = val;
	update_shapes();

func gen_shapes()->void:
	if _n_vis_shape: _n_vis_shape.queue_free()
	if _n_collider: _n_collider.queue_free()
	_n_vis_shape = CSGCylinder3D.new()
	_col_shape = CylinderShape3D.new()
	_n_vis_shape.material = StandardMaterial3D.new()
	_n_collider = CollisionShape3D.new();
	_n_collider.shape = _col_shape;
	update_shapes();

func update_shapes()->void:
	_n_vis_shape.height = _params.h;
	_n_vis_shape.radius = _params.r;
	_n_vis_shape.sides = _params.sides;
	_n_vis_shape.cone = _params.cone;
	_col_shape.height = _params.h;
	_col_shape.radius = _params.r;
