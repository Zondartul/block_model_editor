extends Control

var shapes = []
var gizmo_selected_shape = null
var mat_outline = null

@onready var scene = $BC/BC_center/SubViewportContainer/SubViewport/Scene3D
@onready var shape_list = $BC/BC_left/shape_list
@onready var camera = $BC/BC_center/SubViewportContainer/SubViewport/Scene3D/Camera3D

func ready():
	#generate a material for selected object outline
	mat_outline = StandardMaterial3D.new()
	mat_outline.rim_enabled = true
	mat_outline.rim = 0.25
	mat_outline.disable_receive_shadows = true

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
		var shape_info = get_shape_info(hit.collider)
		if shape_info:
			print("this is ["+shape_info.body.name+"]")
			shape_click(shape_info);
		else:
			print("not ours")
	else:
		print("no hit")

func get_shape_info(collider):
	for shape_info in shapes:
		if(shape_info.body == collider):
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
	
func deselect_shape():
	if gizmo_selected_shape:
		gizmo_selected_shape.queue_free()
	gizmo_selected_shape = null

func select_shape(shape_info):
	var vis_shape:Node3D = shape_info.vis_shape;
	gizmo_selected_shape = vis_shape.duplicate()
	gizmo_selected_shape.scale *= 1.1;
	gizmo_selected_shape.material = mat_outline;
	gizmo_selected_shape.flip_faces = true;
	scene.add_child(gizmo_selected_shape);
	
