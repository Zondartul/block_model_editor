extends Node

#DataView: View of the MVC.
# corresponding Controller pokes at this.
# This does not poke at the controller (except for raw input event pass-through)
# View has "read-only" access to model to render the data

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
