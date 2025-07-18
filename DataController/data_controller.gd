extends Node
# Node: DataController

@export var view:Node;

@onready var cSelection = $Input3D/SelectionController

func connect_signals():
	pass


func shape_click(shape_info):
	if(cSelection.inspector_cur_object == shape_info):
		print("same click!")
		view.n_widget_moveball.next_mode();
	else:
		print("other click!")
		cSelection.deselect_shape();
		cSelection.select_shape(shape_info);

func void_click():
	cSelection.deselect_shape();
#---- util ---
func dicts_equal(dict_A:Dictionary, dict_B:Dictionary):
	return dict_A.hash() == dict_B.hash()


	
#---- end workspace actions -----


# note: signal arguments unnecessary
