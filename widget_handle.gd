@tool
extends StaticBody3D
@export var color:Color = Color.WHITE: 
	set(value):
		mat.albedo_color = value;
		color = value;
@onready var n_cube = $handle_cube
@onready var n_ball = $handle_ball
@onready var n_arrow = $handle_arrow
@onready var mat = n_cube.material #all sub-objects share the same material

#shape is one of: "cube", "ball", "arrow", "none"
func set_shape(shape:String):
	n_cube.hide();
	n_ball.hide();
	n_arrow.hide();
	match shape:
		"cube": n_cube.show();
		"ball": n_ball.show();
		"arrow": n_arrow.show();
		"none": pass;
		_: push_error("widget_handle: set_variant: unexpected shape");
