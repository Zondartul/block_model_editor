extends Node

# ---- body selection ------
func get_shape_info_collider(collider):
	for shape_info in shapes:
		if(shape_info.body == collider):
			return shape_info
	return null

func get_shape_info_idx(idx):
	for shape_info in shapes:
		if(shape_info.list_idx == idx):
			return shape_info
	return null

func deselect_shape():
	#remove_gizmo();
	n_widget_moveball.hide();
	shape_list.deselect_all();
	close_inspector();
	inspector_cur_object = null;

func select_shape(shape_info):
	selection_gizmo.attach(shape_info); #apply_gizmo(shape_info)
	n_widget_moveball.mode = "move_idle";
	n_widget_moveball.position = shape_info.body.position;
	n_widget_moveball.show();
	shape_list.select(shape_info.list_idx)
	open_inspector(shape_info);

func _on_shape_list_item_selected(index: int) -> void:
	var shape_info =  get_shape_info_idx(index);
	deselect_shape() # got to clean up correctly
	select_shape(shape_info);
#----- end body selection ------
