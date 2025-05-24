extends Control

var shapes = []
var gizmo_anchor = null
var mat_outline = null
var inspector_cur_object = null

# need to preload my classes so Godot registers them as types
# note: const ShapeGenerator = preload(...) -> warning "constant has same name as global class"
# note: Autoload ShapeGen.gd as ShapeGen -> warning "class_name conflicts with Singleton name"
# these variables are unused but needed to load the scripts.
const class_ShapeGenerator = preload("res://ShapeGen.gd");
const class_ShapeGenBox = preload("res://ShapeGenBox.gd");
const class_ShapeGenCylinder = preload("res://ShapeGenCylinder.gd");
const class_ShapeGenSphere = preload("res://ShapeGenSphere.gd");

@onready var scene = $BC/BC_center/SubViewportContainer/SubViewport/Scene3D
@onready var shape_list = $BC/BC_left/shape_list
@onready var camera = $BC/BC_center/SubViewportContainer/SubViewport/Scene3D/cam_anchor/Camera3D
@onready var inspector = $BC/BC_right/P_inspector
@onready var n_inspector_grid = $BC/BC_right/P_inspector/BC_inspector/GC_insp_params
#widgets
@onready var n_widget_moveball = $BC/BC_center/SubViewportContainer/SubViewport/Scene3D/widget_moveball

signal mouseover_3d_changed(new_mouseover_3d:Dictionary)

func _ready():
	# generate a material for selected object outline
	mat_outline = StandardMaterial3D.new()
	mat_outline.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED; 
	# initialize inspector panel
	register_inspector();
	

func error(msg:String, show_popup:bool=true, push:bool=true):
	printerr(msg)
	if push: push_error(msg);
	if show_popup: show_error(msg);

func show_error(msg:String):
	var pop = AcceptDialog.new();
	pop.title = "Error";
	pop.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN;
	pop.dialog_text = msg;
	pop.close_requested.connect(pop.queue_free);
	get_tree().root.add_child(pop);
	pop.show()

func create_body(type:String):
	var body = StaticBody3D.new()
	body.name = type;
	var gen:ShapeGenerator;
	match type:
		"box": gen = ShapeGenBox.new();
		"cylinder": gen = ShapeGenCylinder.new();
		"sphere": gen = ShapeGenSphere.new();
		_: error("BadArgument: create_body: type="+type,false); return null;
	gen.gen_shapes();
	gen.attach(body);
	var dict = {"body":body,"generator":gen, "vis_shape":gen.n_vis_shape,"collider":gen.n_collider}
	return dict;

func addShape(type):
	var shape_info = create_body(type)
	if not shape_info: error("Internal: no shape info",true); return;
	shape_info["list_idx"] = 0
	shapes.append(shape_info)
	scene.add_child(shape_info.body)
	update_shape_list()
	print("added "+type)

func update_shape_list():
	shape_list.clear()
	for shape_info in shapes:
		shape_info.list_idx = shape_list.add_item(shape_info.body.name)
		print("dbg:add_item result: "+str(shape_info.list_idx)) #verify that it returns index in Godot 4.4.1

func addBox():	addShape("box")
func addCylinder(): addShape("cylinder")
func addSphere(): addShape("sphere")

func _on_btn_box_pressed() -> void: addBox()
func _on_btn_cylinder_pressed() -> void: addCylinder()
func _on_btn_sphere_pressed() -> void: addSphere()

func _on_sub_viewport_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			match event.button_index:
				MOUSE_BUTTON_LEFT: viewport_click(event.position);
				MOUSE_BUTTON_MIDDLE: viewport_mmb_down(event.position);
				MOUSE_BUTTON_WHEEL_DOWN: viewport_mwheel_down(event.position);
				MOUSE_BUTTON_WHEEL_UP: viewport_mwheel_up(event.position);
				_: pass; # ignore other buttons
		else:
			match event.button_index:
				MOUSE_BUTTON_MIDDLE: viewport_mmb_up(event.position);
				_: pass; # ignore other buttons		
	elif event is InputEventMouseMotion:
		viewport_mouseMove(event.position, event.relative);

var navball_dragging = false;
@onready var n_cam_anchor = $BC/BC_center/SubViewportContainer/SubViewport/Scene3D/cam_anchor
# mouse position argument is unneeded now, but most mouse-based tools will use it.
func viewport_mmb_down(_pos:Vector2): navball_dragging = true;
func viewport_mmb_up(_pos:Vector2): navball_dragging = false;
func viewport_mouseMove(pos:Vector2, rel:Vector2):
	orbit_camera(rel);
	update_3d_mouseover(pos);

func orbit_camera(rel:Vector2):
	var rotation_speed = 0.3;
	var min_pitch = -85.0;
	var max_pitch = 85.0;
	if navball_dragging:
		var current_rotation = n_cam_anchor.rotation_degrees
		var yaw = current_rotation.y - rel.x * rotation_speed
		var pitch = current_rotation.x - rel.y * rotation_speed
		pitch = clamp(pitch, min_pitch, max_pitch)
		n_cam_anchor.rotation_degrees = Vector3(pitch, yaw, 0)

var cam_zoom = 1.0;
var cam_zoom_max = 10.0;
var cam_zoom_min = 0.1;

func viewport_mwheel_down(_pos):
	# zoom out
	cam_zoom = clamp(cam_zoom/1.1, cam_zoom_min, cam_zoom_max);
	if abs(cam_zoom-1.0)<0.05: cam_zoom = 1.0; # snap to correct for accumulating floating-point error
	n_cam_anchor.scale = Vector3.ONE / cam_zoom;
	
func viewport_mwheel_up(_pos):
	# zoom in
	cam_zoom = clamp(cam_zoom*1.1, cam_zoom_min, cam_zoom_max);
	if abs(cam_zoom-1.0)<0.05: cam_zoom = 1.0; # snap to correct for accumulating floating-point error
	n_cam_anchor.scale = Vector3.ONE / cam_zoom;

var mouseover_3d = {"obj":null, "sub_obj":null, "shape_info":null, "name":null, "collider":null, "pos":null};
func clear_mouseover_3d(): for k in mouseover_3d: mouseover_3d[k] = null;

func update_3d_mouseover(mouse_pos:Vector2):
	var old_mouseover_3d = mouseover_3d.duplicate();
	clear_mouseover_3d();
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_dir = camera.project_ray_normal(mouse_pos)
	#print("Ray origin: ", ray_origin, " | Direction: ", ray_dir)
	var space_state = camera.get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.create(ray_origin, ray_origin + ray_dir * 1000.0)
	var hit = space_state.intersect_ray(ray_query)
	if hit:
		#print("hit "+hit.collider.name)
		var shape_info = get_shape_info_collider(hit.collider)
		if shape_info:
			#print("this is ["+shape_info.body.name+"]")
			mouseover_3d.shape_info = shape_info;
			mouseover_3d.obj = shape_info.body;
			mouseover_3d.collider = hit.collider;
			#shape_click(shape_info);
		elif n_widget_moveball.visible and n_widget_moveball.is_ancestor_of(hit.collider):
			#print("hit moveball")
			mouseover_3d.obj = n_widget_moveball;
			mouseover_3d.sub_obj = hit.collider.get_parent();
			mouseover_3d.collider = hit.collider;
		# if collider is not from a recognized body, do not record it.
	if not dicts_equal(old_mouseover_3d, mouseover_3d):
		mouseover_3d_changed.emit(mouseover_3d.duplicate())
		#print("new mouseover: "+str(mouseover_3d))
		#else:
			#print("not ours")
			#void_click();
	#else:
		#print("no hit")
		#void_click();

func dicts_equal(dict_A:Dictionary, dict_B:Dictionary):
	return dict_A.hash() == dict_B.hash()

func viewport_click(mouse_pos:Vector2):
	print("Mouse clicked at: ", mouse_pos)
	update_3d_mouseover(mouse_pos);
	if mouseover_3d.shape_info: shape_click(mouseover_3d.shape_info);
	else: void_click();

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

func _on_btn_clear_pressed() -> void:
	deselect_shape();
	for shape_info in shapes:
		shape_info.body.queue_free()
	shape_list.clear()
	shapes.clear()

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
	
func deselect_shape():
	remove_gizmo();
	n_widget_moveball.hide();
	shape_list.deselect_all();
	close_inspector();
	inspector_cur_object = null;
	
func remove_gizmo():
	if gizmo_anchor:
		gizmo_anchor.queue_free()
	gizmo_anchor = null

func apply_gizmo(shape_info):
	remove_gizmo();
	var vis_shape:Node3D = shape_info.vis_shape;
	var gizmo = vis_shape.duplicate();
	gizmo.scale *= 1.05;
	gizmo.material = mat_outline;
	gizmo.flip_faces = true;
	gizmo_anchor = Node3D.new();
	gizmo_anchor.add_child(gizmo);
	shape_info.body.add_child(gizmo_anchor);

func reapply_gizmo():
	var shape = inspector_cur_object;
	remove_gizmo();
	if shape: apply_gizmo(shape);

func select_shape(shape_info):
	apply_gizmo(shape_info)
	n_widget_moveball.mode = "move_idle";
	n_widget_moveball.position = shape_info.body.position;
	n_widget_moveball.show();
	shape_list.select(shape_info.list_idx)
	open_inspector(shape_info);

func _on_shape_list_item_selected(index: int) -> void:
	var shape_info =  get_shape_info_idx(index);
	deselect_shape() # got to clean up correctly
	select_shape(shape_info);

# note: signal arguments unnecessary
func _on_shape_list_empty_clicked(_at_position: Vector2, _mouse_button_index: int) -> void:
	deselect_shape();
	
func open_inspector(shape_info):
	inspector_cur_object = shape_info;
	populate_inspector_params();
	inspector.show()
	update_inspector();

func close_inspector(): 
	inspector.hide();
	depopulate_inspector_params();

var inspector_ignore_signals = false;
func on_inspector_changed(_dummy):
	if inspector_ignore_signals: return;
	print("inspector changed");
	write_inspector();
	update_inspector();
	reapply_gizmo();

func register_inspector():
	var col_picker:ColorPickerButton = inspector.find_child("col_picker");
	var le_pos:LineEdit = inspector.find_child("lePos");
	var le_rot:LineEdit = inspector.find_child("leRot");
	col_picker.color_changed.connect(on_inspector_changed);
	le_pos.text_submitted.connect(on_inspector_changed);
	le_rot.text_submitted.connect(on_inspector_changed);

func update_inspector():
	inspector_ignore_signals = true;
	var lblName:Label = inspector.find_child("lblName");
	var col_picker:ColorPickerButton = inspector.find_child("col_picker");
	var le_pos:LineEdit = inspector.find_child("lePos");
	var le_rot:LineEdit = inspector.find_child("leRot");
	var obj = inspector_cur_object;
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
	var col_picker:ColorPickerButton = inspector.find_child("col_picker");
	var le_pos:LineEdit = inspector.find_child("lePos");
	var le_rot:LineEdit = inspector.find_child("leRot");
	var obj = inspector_cur_object;
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

var inspector_param_widgets = {}

func populate_inspector_params():
	var params = inspector_cur_object.generator.get_param_list();
	for p in params:
		var lbl = Label.new()
		lbl.text = p.name;
		n_inspector_grid.add_child(lbl);
		var entry;
		# per-type settings
		match p.type:
			"float":
				entry = SpinBox.new()
				entry.step = 0.01;
			"int":
				entry = SpinBox.new()
				entry.step = 1.0;
				entry.rounded = true;
			"bool":
				entry = CheckBox.new()
			_:
				error("Internal: Inspector: unexpected param type "+str(p.type));
				close_inspector();
				return;
		# per-entry method settings
		match entry.get_class():
			"SpinBox":
				entry.value_changed.connect(on_inspector_changed);
				if p.range:
					entry.min_value = p.range[0];
					entry.max_value = p.range[1];
					entry.allow_greater = false;
					entry.allow_lesser = false;
			"CheckBox":
				entry.toggled.connect(on_inspector_changed);
			_:
				error("Internal: Inspector: unexpected widget type");
				close_inspector();
				return;
		inspector_param_widgets[p.name] = entry; # record the param-widget pair
		n_inspector_grid.add_child(entry);
	inspector_ignore_signals = true;
	update_inspector_params();
	inspector_ignore_signals = false;

func depopulate_inspector_params():
	inspector_param_widgets.clear()
	var chs = n_inspector_grid.get_children().duplicate()
	for ch in chs: 
		n_inspector_grid.remove_child(ch);
		ch.queue_free();

func update_inspector_params():
	for param_name in inspector_param_widgets:
		var entry = inspector_param_widgets[param_name];
		var param_val = inspector_cur_object.generator.get_param(param_name);
		match entry.get_class():
			"SpinBox": entry.value = param_val;
			"CheckBox": entry.button_pressed = param_val;
			_: 
				error("Internal: Inspector: unexpected widget type");
				close_inspector();
				return;

func write_inspector_params():
	for param_name in inspector_param_widgets:
		var entry = inspector_param_widgets[param_name];
		var entry_val;
		match entry.get_class():
			"SpinBox": entry_val = entry.value;
			"CheckBox": entry_val = entry.button_pressed;
			_: 
				error("Internal: Inspector: unexpected widget type");
				close_inspector();
				return;
		inspector_cur_object.generator.set_param(param_name, entry_val);
