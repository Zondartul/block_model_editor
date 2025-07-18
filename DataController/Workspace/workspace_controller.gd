extends Node
# Node: WorkspaceController

@export var view:Node;
@export var cData:Node;
@export var vData:Node;
@export var mData:Node;
@export var cFile:Node;
@export var cSelection:Node;
@export var vSelection:Node;

#@onready var scene = $BC/BC_middle/BC_center/SubViewportContainer/SubViewport/Scene3D
@export var scene:Node;

const class_BodyHandle = preload("res://DataController/Workspace/body_handle.gd");

#----list of body handles lives in the controller and provides a link ----------------#
#------------ between transient UI state and persistent DataModel --------------------#
#--------------- body handles are discarded when program closes ----------------------#
#var shapes = []
var body_handles = [];

func add_body_handle(body_item:DMItemBody):
	var handle = BodyHandle.new(body_item);
	body_handles.append(handle);
	return handle;

func remove_body_handle(body_handle:BodyHandle):
	remove_from_scene(body_handle);
	body_handles.erase(body_handle);

func clear_body_handles():
	for bh in body_handles:
		remove_from_scene(bh);
	body_handles.clear();

func add_to_scene(body_handle:BodyHandle):
	# Populate view components
	var body = StaticBody3D.new();
	var gen:ShapeGenerator = body_handle.body_item.generator.generator;
	gen.gen_shapes();
	gen.attach(body);
	body_handle.viewport_nodes.merge({"body":body, "vis_shape":gen.n_vis_shape, "collider":gen.n_collider}, true);
	# put the view components into the scene
	scene.add_child(body);

func remove_from_scene(body_handle:BodyHandle):
	body_handle.viewport_nodes["body"].queue_free();
	body_handle.body_item.generator.cleanup();
	for key in ['body', 'vis_shape', 'collider']:
		body_handle.viewport_nodes.erase(key)

#------------------------------ end body handles -------------------------------------#

#----- workspace actions ------
	
func clear_workspace():
	cSelection.deselect_shape();
	view.clear_shape_list();
	clear_body_handles();

func create_body(type:String)->BodyHandle:
	# Create item in DataModel
	var body_item = DMItemBody.new(type);
	if not body_item: vData.error("Internal: can't create body",true); return;
	mData.add_body(body_item);
	# Create a handle for it
	var handle = add_body_handle(body_item);
	add_to_scene(handle);
	# update everyone interested (should be a signal)
	view.update_shape_list()
	print("added "+type)
	cFile.on_project_changed();
	return handle;


func addBox():	create_body("box")
func addCylinder(): create_body("cylinder")
func addSphere(): create_body("sphere")

# ------- Input handling -------------------
# ------- Input from UI --------------------
func _on_btn_box_pressed() -> void: addBox()
func _on_btn_cylinder_pressed() -> void: addCylinder()
func _on_btn_sphere_pressed() -> void: addSphere()
func _on_btn_clear_pressed() -> void: clear_workspace();
