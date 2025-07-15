extends Node



func viewport_click(mouse_pos:Vector2):
	print("Mouse clicked at: ", mouse_pos)
	update_3d_mouseover(mouse_pos);
	if mouseover_3d.shape_info: shape_click(mouseover_3d.shape_info);
	else: void_click();

func shape_click(shape_info):
	if(inspector_cur_object == shape_info):
		print("same click!")
		n_widget_moveball.next_mode();
	else:
		print("other click!")
		deselect_shape();
		select_shape(shape_info);

func void_click():
	deselect_shape();
#---- util ---
func dicts_equal(dict_A:Dictionary, dict_B:Dictionary):
	return dict_A.hash() == dict_B.hash()


	
#---- end workspace actions -----


# note: signal arguments unnecessary
func _on_shape_list_empty_clicked(_at_position: Vector2, _mouse_button_index: int) -> void:
	deselect_shape();
