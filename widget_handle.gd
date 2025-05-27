@tool
extends StaticBody3D
@export var color:Color = Color.WHITE: 
	set(value):
		assert(mat, "don't set this property before _ready()/add_child")
		mat.albedo_color = value;
		color = value;

@onready var n_cube = $shape_cube
@onready var n_ball = $shape_ball
@onready var n_arrow= $shape_arrow
@onready var mat = n_cube.material #all sub-objects share the same material
@onready var ifx_mouse_3d = $mouse_handler #externally referenced

var vis_shape;
var shape:String;

func _ready():
	set_shape("arrow");

#shape is one of: "cube", "ball", "arrow"
func set_shape(new_shape:String):
	if new_shape == shape: return;
	shape = new_shape;
	n_cube.hide();
	n_ball.hide();
	n_arrow.hide();
	match shape:
		"cube": n_cube.show(); vis_shape = n_cube;
		"ball": n_ball.show(); vis_shape = n_ball;
		"arrow": n_arrow.show(); vis_shape = n_arrow;
		# "none" is not allowed because we must always have a valid vis_shape
		_: push_error("widget_handle: set_variant: unexpected shape");
