extends Node
class_name ShapeGenerator

# Abstract class.
# Each instance of ShapeGenerator manages a single Shape
# which is represented by a collision node and a visual node.
# Each derived generator represents a particular shape (Box, Cylinder, etc)
# and comes with a set of parameters relevant to that shape (length, width)

signal generator_params_changed;
signal generator_shapes_changed;

var _n_collider:Node = null;
var _n_vis_shape:Node = null;

# generates the associated shapes.
func gen_shapes() -> void: 
	push_error("pure virtual function");
	generator_shapes_changed.emit(); #example
	pass;

# updates the associated shapes with new params.
func update_shapes() -> void: 
	push_error("pure virtual function");
	generator_shapes_changed.emit(); #example
	pass;

# adds the managed shapes to body
func attach(parent:Node) -> void:
	parent.add_child(_n_collider);
	parent.add_child(_n_vis_shape);

# removes the managed shapes from their body
func detach() -> void:
	if _n_collider.get_parent():	_n_collider.get_parent().remove_child(_n_collider);
	if _n_vis_shape.get_parent(): _n_vis_shape.get_parent().remove_child(_n_vis_shape);

# cleans up resources when no longer needed
func cleanup() -> void:
	detach()
	if _n_collider:
		_n_collider.queue_free()
		_n_collider = null
	if _n_vis_shape:
		_n_vis_shape.queue_free()
		_n_vis_shape = null

# returns an array of {name,type,range} params
func get_param_list() -> Array: 
	push_error("pure virtual function");
	return [];

# returns the value of a parameter
func get_param(_name:String) -> Variant: 
	push_error("pure virtual function");
	return null;

# sets the parameter
func set_param(_name:String, _val:Variant) -> void: 
	push_error("pure virtual function");
	pass;

# sets all parameters in the order they are listed in get_param_list()
func set_params(params:Array) -> void:
	var param_list = get_param_list()
	for i in range(0, min(param_list.size(), params.size())):
		assert("name" in param_list[i], "ShapeGenerator.get_param_list() must be formatted as an array of {name,type,range} dicts")
		set_param(param_list[i].name, params[i]);
	generator_params_changed.emit();
