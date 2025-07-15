extends Control

var shapes = []
var inspector_cur_object = null
var selection_gizmo;
var mouseover_gizmo;

# need to preload my classes so Godot registers them as types
# note: const ShapeGenerator = preload(...) -> warning "constant has same name as global class"
# note: Autoload ShapeGen.gd as ShapeGen -> warning "class_name conflicts with Singleton name"
# these variables are unused but needed to load the scripts.
const class_ShapeGenerator = preload("res://ShapeGen.gd");
const class_ShapeGenBox = preload("res://ShapeGenBox.gd");
const class_ShapeGenCylinder = preload("res://ShapeGenCylinder.gd");
const class_ShapeGenSphere = preload("res://ShapeGenSphere.gd");

const script_gizmo_outline = preload("res://gizmo_outline.gd");

@onready var scene = $BC/BC_middle/BC_center/SubViewportContainer/SubViewport/Scene3D
@onready var shape_list = $BC/BC_middle/BC_left/shape_list
@onready var camera = $BC/BC_middle/BC_center/SubViewportContainer/SubViewport/Scene3D/cam_anchor/Camera3D
@onready var inspector = $BC/BC_middle/BC_right/P_inspector
@onready var n_inspector_grid = $BC/BC_middle/BC_right/P_inspector/BC_inspector/GC_insp_params
#widgets
@onready var n_widget_moveball = $BC/BC_middle/BC_center/SubViewportContainer/SubViewport/Scene3D/widget_moveball

signal mouseover_3d_changed(new_mouseover_3d:Dictionary)

func _ready():
	# initialize inspector panel
	register_inspector();
	selection_gizmo = script_gizmo_outline.new()
	mouseover_gizmo = script_gizmo_outline.new()
	mouseover_gizmo.thickness = 1.1;





	
