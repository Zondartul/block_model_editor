extends Node
class_name ShapeGenerator

# Abstract class.
# Each instance of ShapeGenerator manages a single Shape
# which is represented by a collision node and a visual node.
# Each derived generator represents a particular shape (Box, Cylinder, etc)
# and comes with a set of parameters relevant to that shape (length, width)

var n_collider:Node = null;
var n_vis_shape:Node = null;

# generates the associated shapes.
func gen_shapes() -> void: pass;

# updates the associated shapes with new params.
func update_shapes() -> void: pass;

# adds the managed shapes to body
func attach(parent:Node) -> void:
	parent.add_child(n_collider);
	parent.add_child(n_vis_shape);

# removes the managed shapes from their body
func detach() -> void:
	if n_collider.get_parent():	n_collider.get_parent().remove_child(n_collider);
	if n_vis_shape.get_parent(): n_vis_shape.get_parent().remove_child(n_vis_shape);

# cleans up resources when no longer needed
func cleanup() -> void:
	detach()
	if n_collider:
		n_collider.queue_free()
		n_collider = null
	if n_vis_shape:
		n_vis_shape.queue_free()
		n_vis_shape = null

# returns an array of {name,type,range} params
func get_param_list() -> Array: return [];

# returns the value of a parameter
func get_param(_name:String) -> Variant: return null;

# sets the parameter
func set_param(_name:String, _val:Variant) -> void: pass;

# sets all parameters in the order they are listed in get_param_list()
func set_params(params:Array) -> void:
	var param_list = get_param_list()
	for i in range(0, min(param_list.size(), params.size())):
		assert("name" in param_list[i], "ShapeGenerator.get_param_list() must be formatted as an array of {name,type,range} dicts")
		set_param(param_list[i].name, params[i]);
