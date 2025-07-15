extends Node

@onready var cFile = $FileController
@onready var cInspector = $Inspector
@onready var cInput3D = $Input3D
@onready var cSelection = $SelectionController
@onready var cWorkspace = $WorkspaceController

func connect_signals():
	pass


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
