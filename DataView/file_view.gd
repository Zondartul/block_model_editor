extends Node
# Node: FileView
@export var n_mb:Node;

@onready var n_FD:FileDialog = $FileDialog

func update_file_dirty_indicator(is_dirty):
	#var n_mb = $BC/PC_menu/MenuBar
	var title = "File";
	#if cur_file.is_dirty: title += "*";
	if is_dirty: title += "*";
	n_mb.set_menu_title(0,title);
	n_mb.hide()
	n_mb.show()
