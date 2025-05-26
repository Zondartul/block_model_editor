extends Node

@export var thickness = 1.05;
var target = null;	# what the gizmo is attached to
var gizmo_anchor:Node3D = null;	# gizmo attachment point
var mat_outline:Material = null;		# material the gizmo uses
var is_attached:bool = false; # is the gizmo attached to something? same as (target != null)

func _init() -> void:
	# generate a material for the outline
	mat_outline = StandardMaterial3D.new()
	mat_outline.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED; 

func detach()->void: #remove_gizmo() -> void:
	target = null;
	is_attached = false;
	if gizmo_anchor:
		gizmo_anchor.queue_free()
	gizmo_anchor = null

func attach(shape_info)->void: #apply_gizmo(shape_info) -> void:
	detach(); #remove_gizmo();
	target = shape_info;
	var vis_shape:Node3D = shape_info.vis_shape;
	assert(vis_shape);
	var gizmo = vis_shape.duplicate();
	gizmo.scale *= thickness;
	recursive_apply_material(gizmo);
	gizmo_anchor = Node3D.new();
	gizmo_anchor.add_child(gizmo);
	shape_info.body.add_child(gizmo_anchor);
	is_attached = true;

func recursive_apply_material(node):
	if "material" in node:
		node.material = mat_outline;
	if "flip_faces" in node:
		node.flip_faces = true;
	for ch in node.get_children():
		recursive_apply_material(ch);

func update() -> void: #reapply_gizmo() -> void:
	var prev_target = target;
	detach();
	if prev_target: attach(prev_target);
