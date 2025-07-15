extends Node

var view;

# Feature-File state
const cur_file_default = {"filename":"", "is_open":false, "is_dirty":false}
var cur_file = cur_file_default.duplicate();

const MENU_BTN_FILE_NEW = 0
const MENU_BTN_FILE_OPEN = 1
const MENU_BTN_FILE_SAVE = 2
const MENU_BTN_FILE_SAVE_AS = 3
@onready var n_FD:FileDialog = $FileDialog
const class_Promise = preload("res://Promise.gd")
# for MenuBar - File menu
func _on_file_id_pressed(id: int) -> void:
	match id:
		MENU_BTN_FILE_NEW: NewFile();
		MENU_BTN_FILE_OPEN: OpenFile();
		MENU_BTN_FILE_SAVE: SaveFile();
		MENU_BTN_FILE_SAVE_AS: SaveFileAs();
		
func NewFile():
	var go = await clear_dirty_file();
	if not go: return;
	clear_workspace();
	cur_file = cur_file_default.duplicate()
	view.update_file_dirty_indicator(cur_file.is_dirty)

func OpenFile():
	var go = await clear_dirty_file();
	if not go: return;
	n_FD.file_mode = n_FD.FILE_MODE_OPEN_FILE;
	n_FD.title = "Open File"
	n_FD.show()
	var res = await Promise.new(n_FD.file_selected)._else(n_FD.canceled, 0).wait();
	if res.success:
		OpenFileActual(res.data);
	else:
		print("no file selected")
		return;
		
func OpenFileActual(filename):
	print("open the file "+str(filename))
	cur_file.filename = filename;
	cur_file.is_open = true;
	var file = FileAccess.open(filename, FileAccess.READ);
	if(file):
		var data = file.get_as_text()
		DeserializeProject(data);
	else:
		push_error("Can't open file for reading: "+str(FileAccess.get_open_error()))
	cur_file.is_dirty = false;
	view.update_file_dirty_indicator(cur_file.is_dirty)
	
func SaveFile():
	if cur_file.filename == "":
		SaveFileAs();
	else:
		SaveFileActual(cur_file.filename);

func SaveFileActual(filename):
	print("save the file "+str(filename))
	cur_file.filename = filename;
	cur_file.is_open = true;
	var file = FileAccess.open(filename, FileAccess.WRITE);
	if(file):
		var data = SerializeProject();
		file.store_string(data);
	else:
		push_error("Can't open file for writing: "+str(FileAccess.get_open_error()))
		return false;
	cur_file.is_dirty = false;
	view.update_file_dirty_indicator(cur_file.is_dirty)
	return true;

func SaveFileAs():
	n_FD.file_mode = n_FD.FILE_MODE_SAVE_FILE;
	n_FD.title = "Save File"
	n_FD.show()
	var res = await Promise.new(n_FD.file_selected)._else(n_FD.canceled, 0).wait();
	if res.success:
		return SaveFileActual(res.data);
	else:
		print("no file selected")
		return false;

# if the current file has unsaved changes, asks the user to save them.
# returns true when it is safe to proceed.
# returns false if the user cancels.
func clear_dirty_file():
	if cur_file.is_dirty:
		var pop = show_popup("Current file has changes, save it?", "Warning");
		var res = await Promise.new(pop.confirmed,0)._else(pop.canceled,0).wait();
		if res.success:	return await SaveFile();
		else:			return false;
	else:
		return true;

func on_project_changed():
	cur_file.is_dirty = true;
	view.update_file_dirty_indicator(cur_file.is_dirty)

func DeserializeProject(data:String)->void:
	push_warning("Warning: dummy func");
	print(data);

func SerializeProject()->String:
	push_warning("Warning: dummy func");
	return "<dummy data>";
