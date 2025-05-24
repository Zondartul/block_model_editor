extends Node3D

@onready var axis_x = $axis_x
@onready var axis_y = $axis_y
@onready var axis_z = $axis_z
@onready var ring_zy = $ring_zy
@onready var ring_zx = $ring_zx
@onready var ring_xy = $ring_xy
@onready var nodes = [axis_x, axis_y, axis_z, ring_zy, ring_zx, ring_xy];
@onready var handles = find_children("handle_*");

var mode:String = "move_idle":
	set(new_mode):
		if not new_mode in vis_configs: push_error("widget_moveball: set_mode: unknown mode"); return;
		mode = new_mode;
		var cfg = vis_configs[mode]; #assume vis_configs is well-formed
		for handle in handles:	handle.set_shape(cfg[0]);			#choose box, ball or arrow
		for i in range(0,6):	nodes[i].visible = bool(cfg[i+1]);	#show or hide control elements

const vis_configs = {
	# config_name : [ handle_style, node_visible: x, y, z, zy, zx, xy ]
	"none": 		["none", 	0,0,0,0,0,0],
	
	"move_idle":	["arrow",	1,1,1,0,0,0],
	"move_x":		["arrow",	1,0,0,0,0,0],
	"move_y":		["arrow",	0,1,0,0,0,0],
	"move_z":		["arrow",	0,0,1,0,0,0],
	
	"rotate_idle":	["ball",	1,1,1,0,0,0],
	"rotate_x":		["ball",	1,0,0,1,0,0],
	"rotate_y":		["ball",	0,1,0,0,1,0],
	"rotate_z":		["ball",	0,0,1,0,0,1],
	
	"scale_idle":	["cube",	1,1,1,0,0,0],
	"scale_x":		["cube",	1,0,0,0,0,0],
	"scale_y":		["cube",	0,1,0,0,0,0],
	"scale_z":		["cube",	0,0,1,0,0,0],
}

func _ready():
	pass

func next_mode():
	var new_mode;
	if   mode.begins_with("move_"): new_mode = "rotate_idle";
	elif mode.begins_with("rotate_"): new_mode = "scale_idle";
	elif mode.begins_with("scale_"): new_mode = "move_idle";
	mode = new_mode;
