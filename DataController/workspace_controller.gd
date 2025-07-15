extends Node

#----- workspace actions ------
func _on_btn_clear_pressed() -> void:
	clear_workspace();
	
func clear_workspace():
	deselect_shape();
	for shape_info in shapes:
		shape_info.body.queue_free()
	shape_list.clear()
	shapes.clear()

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
	on_project_changed();

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
