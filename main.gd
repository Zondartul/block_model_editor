extends Control

var shapes = []
var gizmo_anchor = null
var mat_outline = null
var inspector_cur_object = null

@onready var scene = $BC/BC_center/SubViewportContainer/SubViewport/Scene3D
@onready var shape_list = $BC/BC_left/shape_list
@onready var camera = $BC/BC_center/SubViewportContainer/SubViewport/Scene3D/Camera3D
@onready var inspector = $BC/BC_right/P

func _ready():
	# generate a material for selected object outline
	mat_outline = StandardMaterial3D.new()
	mat_outline.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED; 
	# initialize inspector panel
	register_inspector();
	

func create_body(type):
	var body = StaticBody3D.new()
	body.name = type;
	var vis_shape;
	var col_shape;
	if type == "box":
		vis_shape = CSGBox3D.new()
		col_shape = BoxShape3D.new()
	elif type == "cylinder":
		vis_shape = CSGCylinder3D.new()
		col_shape = CylinderShape3D.new()
	vis_shape.material = StandardMaterial3D.new()
	body.add_child(vis_shape);
	var collider = CollisionShape3D.new();
	collider.shape = col_shape;
	body.add_child(collider);
	var dict = {"body":body,"vis_shape":vis_shape,"col_shape":col_shape,"collider":collider}
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

func _on_btn_box_pressed() -> void: addBox()
func _on_btn_cylinder_pressed() -> void: addCylinder()


func _on_sub_viewport_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			viewport_click(event.position)

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
	inspector.show()
	update_inspector();

func close_inspector(): inspector.hide();

func on_inspector_changed(_dummy):
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
