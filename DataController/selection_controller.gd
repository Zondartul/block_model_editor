extends Node
# Node: SelectionController

@export var vWorkspace:Node;
@export var cWorkspace:Node;
@export var view:Node;
@export var cInspector:Node;

var inspector_cur_object = null # rename to "selected object" or maybe "object handle"

# ---- body selection ------
func get_body_handle_from_collider(collider:Node)->BodyHandle:
	for body_handle in cWorkspace.body_handles:
		if(body_handle.viewport_nodes["body"] == collider):
			return body_handle
	return null

func get_body_handle_from_idx(idx):
	for body_handle in cWorkspace.body_handles:
		if(body_handle.view_data["list_idx"] == idx):
			return body_handle
	return null

func deselect_shape():
	#remove_gizmo();
	view.n_widget_moveball.hide();
	vWorkspace.deselect_shape_list();
	cInspector.close_inspector();
	inspector_cur_object = null;

func select_shape(body_handle:BodyHandle):
	view.selection_gizmo.attach(body_handle); #apply_gizmo(shape_info)
	view.n_widget_moveball.mode = "move_idle";
	view.n_widget_moveball.position = body_handle.body_item.position;
	view.n_widget_moveball.show();
	vWorkspace.select_shape_list(body_handle.view_data["list_idx"])
	cInspector.open_inspector(body_handle);

func _on_shape_list_item_selected(index: int) -> void:
	var body_handle =  get_body_handle_from_idx(index);
	deselect_shape() # got to clean up correctly
	select_shape(body_handle);
#----- end body selection ------

func _on_shape_list_empty_clicked(_at_position: Vector2, _mouse_button_index: int) -> void:
	deselect_shape();
