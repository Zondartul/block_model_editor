extends Node
# Node: SelectionController

@export var cWorkspace:Node;
@export var view:Node;
@export var cInspector:Node;

var inspector_cur_object = null # rename to "selected object" or maybe "object handle"

# ---- body selection ------
func get_shape_info_collider(collider):
	for shape_info in cWorkspace.shapes:
		if(shape_info.body == collider):
			return shape_info
	return null

func get_shape_info_idx(idx):
	for shape_info in cWorkspace.shapes:
		if(shape_info.list_idx == idx):
			return shape_info
	return null

func deselect_shape():
	#remove_gizmo();
	view.n_widget_moveball.hide();
	view.shape_list.deselect_all();
	cInspector.close_inspector();
	inspector_cur_object = null;

func select_shape(shape_info):
	view.selection_gizmo.attach(shape_info); #apply_gizmo(shape_info)
	view.n_widget_moveball.mode = "move_idle";
	view.n_widget_moveball.position = shape_info.body.position;
	view.n_widget_moveball.show();
	view.shape_list.select(shape_info.list_idx)
	cInspector.open_inspector(shape_info);

func _on_shape_list_item_selected(index: int) -> void:
	var shape_info =  get_shape_info_idx(index);
	deselect_shape() # got to clean up correctly
	select_shape(shape_info);
#----- end body selection ------

func _on_shape_list_empty_clicked(_at_position: Vector2, _mouse_button_index: int) -> void:
	deselect_shape();
