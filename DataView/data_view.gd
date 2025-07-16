extends Node
# Node: DataView

#DataView: View of the MVC.
# corresponding Controller pokes at this.
# This does not poke at the controller (except for raw input event pass-through)
# View has "read-only" access to model to render the data

#MVC Views
@onready var vFile = $FileView
@onready var vInspector = $InspectorView

#MVC Controllers (for input passhthrough)
@export var cInput3D:Node;
@export var cSelection:Node;
@export var cWorkspace:Node;
@export var cFile:Node;

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

# Input event passhthrough

func _on_shape_list_empty_clicked(at_position: Vector2, mouse_button_index: int) -> void:
	cSelection._on_shape_list_empty_clicked(at_position, mouse_button_index);

func _on_sub_viewport_container_gui_input(event: InputEvent) -> void:
	cInput3D._on_sub_viewport_container_gui_input(event);

func _on_btn_box_pressed() -> void:			cWorkspace._on_btn_box_pressed();
func _on_btn_cylinder_pressed() -> void:	cWorkspace._on_btn_cylinder_pressed();
func _on_btn_sphere_pressed() -> void:		cWorkspace._on_btn_sphere_pressed();
func _on_btn_clear_pressed() -> void:		cWorkspace._on_btn_clear_pressed();
func _on_file_id_pressed(id: int) -> void:	cFile._on_file_id_pressed(id);
