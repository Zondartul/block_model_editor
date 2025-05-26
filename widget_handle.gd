@tool
extends StaticBody3D
@export var color:Color = Color.WHITE: 
	set(value):
		if mat: mat.albedo_color = value;
		color = value;

@onready var n_cube = $shape_cube
@onready var n_ball = $shape_ball
@onready var n_arrow= $shape_arrow
@onready var mat = n_cube.material #all sub-objects share the same material
var vis_shape;

func _ready():
	set_shape("arrow");

#shape is one of: "cube", "ball", "arrow", "none"
func set_shape(shape:String):
	n_cube.hide();
	n_ball.hide();
	n_arrow.hide();
	match shape:
		"cube": n_cube.show(); vis_shape = n_cube;
		"ball": n_ball.show(); vis_shape = n_ball;
		"arrow": n_arrow.show(); vis_shape = n_arrow;
		"none": pass;
		_: push_error("widget_handle: set_variant: unexpected shape");
