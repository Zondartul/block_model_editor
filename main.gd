extends Control

var shapes = []
var gizmo_anchor = null
var mat_outline = null
var inspector_cur_object = null

var script_shapegen = preload("res://ShapeGen.gd");
var script_shapegenbox = preload("res://ShapeGenBox.gd");
var script_shapegencylinder = preload("res://ShapeGenCylinder.gd");
var script_shapegensphere = preload("res://ShapeGenSphere.gd");

@onready var scene = $BC/BC_center/SubViewportContainer/SubViewport/Scene3D
@onready var shape_list = $BC/BC_left/shape_list
@onready var camera = $BC/BC_center/SubViewportContainer/SubViewport/Scene3D/cam_anchor/Camera3D
@onready var inspector = $BC/BC_right/P
@onready var n_inspector_grid = $BC/BC_right/P/BC/GC2

func _ready():
	# generate a material for selected object outline
	mat_outline = StandardMaterial3D.new()
	mat_outline.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED; 
	# initialize inspector panel
	register_inspector();
	

#func create_body(type):
	#var body = StaticBody3D.new()
	#body.name = type;
	#var vis_shape;
	#var col_shape;
	#if type == "box":
		#vis_shape = CSGBox3D.new()
		#col_shape = BoxShape3D.new()
	#elif type == "cylinder":
		#vis_shape = CSGCylinder3D.new()
		#col_shape = CylinderShape3D.new()
	#vis_shape.material = StandardMaterial3D.new()
	#body.add_child(vis_shape);
	#var collider = CollisionShape3D.new();
	#collider.shape = col_shape;
	#body.add_child(collider);
	#var dict = {"body":body,"vis_shape":vis_shape,"col_shape":col_shape,"collider":collider}
	#return dict;

func create_body(type):
	var body = StaticBody3D.new()
	body.name = type;
	var gen:ShapeGenerator;
	if type == "box":
		gen = ShapeGenBox.new();
	elif type == "cylinder":
		gen = ShapeGenCylinder.new();
	elif type == "sphere":
		gen = ShapeGenSphere.new();
	gen.gen_shapes();
	gen.attach(body);
	var dict = {"body":body,"generator":gen, "vis_shape":gen.n_vis_shape,"collider":gen.n_collider}
	return dict;

func addShape(type):
	var shape_info = create_body(type)
	shape_info["list_idx"] = 0
	shapes.append(shape_info)
	scene.add_child(shape_info.body)
	update_shape_list()
	print("added "+type)

func update_shape_list():
	shape_list.clear()
	for shape_info in shapes:
		shape_info.list_idx = shape_list.add_item(shape_info.body.name)

func addBox():	addShape("box")
func addCylinder(): addShape("cylinder")
func addSphere(): addShape("sphere")

func _on_btn_box_pressed() -> void: addBox()
func _on_btn_cylinder_pressed() -> void: addCylinder()
func _on_btn_sphere_pressed() -> void: addSphere()

func _on_sub_viewport_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			viewport_click(event.position)
		if event.button_index == MOUSE_BUTTON_MIDDLE and event.pressed:
			viewport_mmb_down(event.position)
		if event.button_index == MOUSE_BUTTON_MIDDLE and not event.pressed:
			viewport_mmb_up(event.position)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			viewport_mwheel_down(event.position)
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			viewport_mwheel_up(event.position)
		
	if event is InputEventMouseMotion:
		viewport_mouseMove(event.position, event.relative);

var navball_dragging = false;
@onready var n_cam_anchor = $BC/BC_center/SubViewportContainer/SubViewport/Scene3D/cam_anchor
func viewport_mmb_down(pos:Vector2): navball_dragging = true;
func viewport_mmb_up(pos:Vector2): navball_dragging = false;
func viewport_mouseMove(pos:Vector2, rel:Vector2):
	#var sensitivity = 0.01;
	var rotation_speed = 0.3;
	var min_pitch = -85.0;
	var max_pitch = 85.0;
	if navball_dragging:
		#n_cam_anchor.rotate_x(-rel.y*sensitivity);
		#n_cam_anchor.rotate_y(-rel.x*sensitivity);
		#n_cam_anchor.rotation.z = 0.0;
				# Current rotation in degrees
		var current_rotation = n_cam_anchor.rotation_degrees
		var yaw = current_rotation.y - rel.x * rotation_speed
		var pitch = current_rotation.x - rel.y * rotation_speed
		pitch = clamp(pitch, min_pitch, max_pitch)
		n_cam_anchor.rotation_degrees = Vector3(pitch, yaw, 0)
		
func viewport_mwheel_down(_pos):
	n_cam_anchor.scale *= 1.1;
	if(abs(n_cam_anchor.scale.x-1.0) < 0.05):
		n_cam_anchor.scale = Vector3(1.0,1.0,1.0);
	
func viewport_mwheel_up(_pos):
	n_cam_anchor.scale /= 1.1;
	if(abs(n_cam_anchor.scale.x-1.0) < 0.05):
		n_cam_anchor.scale = Vector3(1.0,1.0,1.0);

func viewport_click(mouse_pos:Vector2):
	print("Mouse clicked at: ", mouse_pos)
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_dir = camera.project_ray_normal(mouse_pos)
	print("Ray origin: ", ray_origin, " | Direction: ", ray_dir)
	var space_state = camera.get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.create(ray_origin, ray_origin + ray_dir * 1000.0)
	var hit = space_state.intersect_ray(ray_query)
	if hit:
		print("hit "+hit.collider.name)
		var shape_info = get_shape_info_collider(hit.collider)
		if shape_info:
			print("this is ["+shape_info.body.name+"]")
			shape_click(shape_info);
		else:
			print("not ours")
			void_click();
	else:
		print("no hit")
		void_click();

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
	for shape_info in shapes:
		shape_info.body.queue_free()
	shape_list.clear()
	shapes.clear()

func shape_click(shape_info):
	deselect_shape();
	select_shape(shape_info);

func void_click():
	deselect_shape();
	
func deselect_shape():
	remove_gizmo();
	shape_list.deselect_all();
	close_inspector();
	
func remove_gizmo():
	if gizmo_anchor:
		gizmo_anchor.queue_free()
	gizmo_anchor = null

func apply_gizmo(shape_info):
	remove_gizmo();
	var vis_shape:Node3D = shape_info.vis_shape;
	var gizmo = vis_shape.duplicate();
	#gizmo.transform = shape_info.body.transform
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
	shape_list.select(shape_info.list_idx)
	open_inspector(shape_info);

func _on_shape_list_item_selected(index: int) -> void:
	var shape_info =  get_shape_info_idx(index);
	select_shape(shape_info);

func _on_shape_list_empty_clicked(at_position: Vector2, mouse_button_index: int) -> void:
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
	var lblName:Label = inspector.find_child("lblName");
	var col_picker:ColorPickerButton = inspector.find_child("col_picker");
	var le_pos:LineEdit = inspector.find_child("lePos");
	var le_size:LineEdit = inspector.find_child("leSize");
	var le_rot:LineEdit = inspector.find_child("leRot");
	col_picker.color_changed.connect(on_inspector_changed);
	le_pos.text_submitted.connect(on_inspector_changed);
	le_size.text_submitted.connect(on_inspector_changed);
	le_rot.text_submitted.connect(on_inspector_changed);

func update_inspector():
	inspector_ignore_signals = true;
	var lblName:Label = inspector.find_child("lblName");
	var col_picker:ColorPickerButton = inspector.find_child("col_picker");
	var le_pos:LineEdit = inspector.find_child("lePos");
	var le_size:LineEdit = inspector.find_child("leSize");
	var le_rot:LineEdit = inspector.find_child("leRot");
	var obj = inspector_cur_object;
	var body:StaticBody3D = obj.body;
	var vis_shape = obj.vis_shape;
	var mat:StandardMaterial3D = vis_shape.material;
	
	lblName.text = body.name;
	col_picker.color = mat.albedo_color;
	le_pos.text  = str(body.position);
	le_size.text = get_shape_size(obj);
	le_rot.text  = str(body.rotation_degrees);
	update_inspector_params();
	inspector_ignore_signals = false;

func write_inspector():
	var lblName:Label = inspector.find_child("lblName");
	var col_picker:ColorPickerButton = inspector.find_child("col_picker");
	var le_pos:LineEdit = inspector.find_child("lePos");
	var le_size:LineEdit = inspector.find_child("leSize");
	var le_rot:LineEdit = inspector.find_child("leRot");
	var obj = inspector_cur_object;
	var body:StaticBody3D = obj.body;
	var vis_shape = obj.vis_shape;
	var mat:StandardMaterial3D = vis_shape.material;
	
	mat.albedo_color = col_picker.color
	body.position = str_to_vec3(le_pos.text, Vector3());
	set_shape_size(obj, str_to_vec3(le_size.text, Vector3(1,1,1)));
	body.rotation_degrees = str_to_vec3(le_rot.text, Vector3());
	write_inspector_params();
	
func str_to_vec3(string, default):
	var components = string.replace("(","").replace(")","").split_floats(",")
	if len(components) == 3:
		return Vector3(components[0],components[1],components[2])
	else:
		return default;

func get_shape_size(shape_info): #unimplemented
	return str(Vector3(1,1,1));
	
func set_shape_size(shape_info, new_size:Vector3): #unimplemented
	pass

func populate_inspector_params():
	var params = inspector_cur_object.generator.get_param_list();
	for p in params:
		var lbl = Label.new()
		lbl.text = p.name;
		n_inspector_grid.add_child(lbl);
		var entry;
		if p.type == "float":
			entry = SpinBox.new()
			entry.step = 0.01;
		elif p.type == "int":
			entry = SpinBox.new()
			entry.step = 1.0;
			entry.rounded = true;
		elif p.type == "bool":
			entry = CheckBox.new()
		
		if entry:
			if entry is SpinBox:
				entry.value_changed.connect(on_inspector_changed);
				if p.range:
					entry.min_value = p.range[0];
					entry.max_value = p.range[1];
					entry.allow_greater = false;
					entry.allow_lesser = false;
			elif entry is CheckBox:
				entry.toggled.connect(on_inspector_changed);
			n_inspector_grid.add_child(entry);

func depopulate_inspector_params():
	var chs = n_inspector_grid.get_children().duplicate()
	for ch in chs: 
		n_inspector_grid.remove_child(ch);
		ch.queue_free();

func update_inspector_params():
	var controls = n_inspector_grid.get_children();
	for i in range(0, len(controls)/2):
		var lbl = controls[i*2];
		var entry = controls[i*2+1];
		var param_val = inspector_cur_object.generator.get_param(lbl.text);
		if entry is SpinBox:
			entry.value = param_val;
		elif entry is CheckBox:
			entry.button_pressed = param_val;

func write_inspector_params():
	var controls = n_inspector_grid.get_children();
	for i in range(0, len(controls)/2):
		var lbl = controls[i*2];
		var entry = controls[i*2+1];
		var entry_val;
		if entry is SpinBox:
			entry_val = entry.value;
		elif entry is CheckBox:
			entry_val = entry.button_pressed;
		inspector_cur_object.generator.set_param(lbl.text, entry_val);
