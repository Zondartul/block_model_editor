extends Node

#DataView: View of the MVC.
# corresponding Controller pokes at this.
# This does not poke at the controller (except for raw input event pass-through)
# View has "read-only" access to model to render the data

@onready var scene = $BC/BC_middle/BC_center/SubViewportContainer/SubViewport/Scene3D
@onready var shape_list = $BC/BC_middle/BC_left/shape_list
@onready var camera = $BC/BC_middle/BC_center/SubViewportContainer/SubViewport/Scene3D/cam_anchor/Camera3D
@onready var inspector = $BC/BC_middle/BC_right/P_inspector
@onready var n_inspector_grid = $BC/BC_middle/BC_right/P_inspector/BC_inspector/GC_insp_params
#widgets
@onready var n_widget_moveball = $BC/BC_middle/BC_center/SubViewportContainer/SubViewport/Scene3D/widget_moveball

var shapes = []
var inspector_cur_object = null
var selection_gizmo;
var mouseover_gizmo;

func _ready():
	# initialize inspector panel
	register_inspector();
	selection_gizmo = script_gizmo_outline.new()
	mouseover_gizmo = script_gizmo_outline.new()
	mouseover_gizmo.thickness = 1.1;

func error(msg:String, _show_popup:bool=true, push:bool=true):
	printerr(msg)
	if push: push_error(msg);
	if _show_popup: show_error(msg);

func show_popup(msg:String, title:String):
	var pop = AcceptDialog.new();
	pop.title = title;
	pop.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN;
	pop.dialog_text = msg;
	pop.close_requested.connect(pop.queue_free);
	get_tree().root.add_child(pop);
	pop.show()
	return pop;

func show_error(msg:String):
	show_popup(msg, "Error")
