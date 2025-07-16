extends Node
# Node: Inspector

@export var cSelection:Node;
@export var vSelection:Node;
@export var cFile:Node;
@export var vData:Node;
@export var view:Node;

func _ready() -> void:
	# initialize inspector panel
	register_inspector();

func open_inspector(shape_info):
	cSelection.inspector_cur_object = shape_info;
	view.populate_inspector_params();
	view.inspector.show()
	update_inspector();

func close_inspector(): 
	view.inspector.hide();
	view.depopulate_inspector_params();

var inspector_ignore_signals = false;
func on_inspector_changed(_dummy):
	if inspector_ignore_signals: return;
	print("inspector changed");
	write_inspector();
	update_inspector();
	vSelection.selection_gizmo.update(); #reapply_gizmo();
	cFile.on_project_changed();

func register_inspector():
	var col_picker:ColorPickerButton = view.inspector.find_child("col_picker");
	var le_pos:LineEdit = view.inspector.find_child("lePos");
	var le_rot:LineEdit = view.inspector.find_child("leRot");
	col_picker.color_changed.connect(on_inspector_changed);
	le_pos.text_submitted.connect(on_inspector_changed);
	le_rot.text_submitted.connect(on_inspector_changed);

func update_inspector():
	inspector_ignore_signals = true;
	var lblName:Label = view.inspector.find_child("lblName");
	var col_picker:ColorPickerButton = view.inspector.find_child("col_picker");
	var le_pos:LineEdit = view.inspector.find_child("lePos");
	var le_rot:LineEdit = view.inspector.find_child("leRot");
	var obj = cSelection.inspector_cur_object;
	var body:StaticBody3D = obj.body;
	var vis_shape = obj.vis_shape;
	var mat:StandardMaterial3D = vis_shape.material;
	
	lblName.text = body.name;
	col_picker.color = mat.albedo_color;
	le_pos.text  = str(body.position);
	le_rot.text  = str(body.rotation_degrees);
	update_inspector_params();
	inspector_ignore_signals = false;

func write_inspector():
	var col_picker:ColorPickerButton = view.inspector.find_child("col_picker");
	var le_pos:LineEdit = view.inspector.find_child("lePos");
	var le_rot:LineEdit = view.inspector.find_child("leRot");
	var obj = cSelection.inspector_cur_object;
	var body:StaticBody3D = obj.body;
	var vis_shape = obj.vis_shape;
	var mat:StandardMaterial3D = vis_shape.material;
	
	mat.albedo_color = col_picker.color
	body.position = str_to_vec3(le_pos.text, Vector3());
	body.rotation_degrees = str_to_vec3(le_rot.text, Vector3());
	write_inspector_params();
	
func str_to_vec3(string, default):
	var components = string.replace("(","").replace(")","").split_floats(",")
	if len(components) == 3:
		return Vector3(components[0],components[1],components[2])
	else:
		return default;

func update_inspector_params():
	for param_name in view.inspector_param_widgets:
		var entry = view.inspector_param_widgets[param_name];
		var param_val = cSelection.inspector_cur_object.generator.get_param(param_name);
		match entry.get_class():
			"SpinBox": entry.value = param_val;
			"CheckBox": entry.button_pressed = param_val;
			_: 
				vData.error("Internal: Inspector: unexpected widget type");
				close_inspector();
				return;

func write_inspector_params():
	for param_name in view.inspector_param_widgets:
		var entry = view.inspector_param_widgets[param_name];
		var entry_val;
		match entry.get_class():
			"SpinBox": entry_val = entry.value;
			"CheckBox": entry_val = entry.button_pressed;
			_: 
				vData.error("Internal: Inspector: unexpected widget type");
				close_inspector();
				return;
		cSelection.inspector_cur_object.generator.set_param(param_name, entry_val);
