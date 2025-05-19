extends Node
class_name ShapeGenerator

# Abstract class.
# Each instance of ShapeGenerator manages a single Shape
# which is represented by a collision node and a visual node.
# Each derived generator represents a particular shape (Box, Cylinder, etc)
# and comes with a set of parameters relevant to that shape (length, width)

var n_collider:Node = null;
var n_vis_shape:Node = null;

# (re)generates the associated shapes.
func gen_shapes() -> void: pass;

# adds the managed
func attach(parent:Node) -> void:
	parent.add_child(n_collider);
	parent.add_child(n_vis_shape);

# returns an array of {name,type,range} params
func get_param_list() -> Array: return [];

# returns the value of a parameter
func get_param(name:String) -> Variant: return null;

# sets the parameter
func set_param(name:String, val:Variant) -> void: pass;

# sets all parameters in the order they are listed in get_param_list()
func set_params(params:Array) -> void:
	var par_list = get_param_list()
	for i in range(0, min(par_list.size(), params.size())):
		set_param(par_list[i].name, params[i]);
