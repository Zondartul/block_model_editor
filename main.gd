extends Control

# need to preload my classes so Godot registers them as types
# note: const ShapeGenerator = preload(...) -> warning "constant has same name as global class"
# note: Autoload ShapeGen.gd as ShapeGen -> warning "class_name conflicts with Singleton name"
# these variables are unused but needed to load the scripts.
const class_ShapeGenerator = preload("res://ShapeGen.gd");
const class_ShapeGenBox = preload("res://ShapeGenBox.gd");
const class_ShapeGenCylinder = preload("res://ShapeGenCylinder.gd");
const class_ShapeGenSphere = preload("res://ShapeGenSphere.gd");

const script_gizmo_outline = preload("res://gizmo_outline.gd");


signal mouseover_3d_changed(new_mouseover_3d:Dictionary)

func _ready():
	pass
