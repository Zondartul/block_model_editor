extends Node
# Node: Mouseover

@export var view:Node;
#@onready var camera = $BC/BC_middle/BC_center/SubViewportContainer/SubViewport/Scene3D/cam_anchor/Camera3D
@export var camera:Camera3D;
@export var cSelection:Node; #for get_shape_info_collider
@export var cData:Node; # for util/dicts_equal

#-------- 3D mouseover and clicking ---------
var mouseover_3d = {"obj":null, "sub_obj":null, "shape_info":null, "name":null, "pos":null};
func clear_mouseover_3d(): for k in mouseover_3d: mouseover_3d[k] = null;

signal mouseover_3d_changed(new_mouseover_3d:Dictionary)

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
		var shape_info = cSelection.get_shape_info_collider(hit.collider)
		mouseover_3d.obj = hit.collider;
		if shape_info:
			mouseover_3d.shape_info = shape_info;
	if not cData.dicts_equal(old_mouseover_3d, mouseover_3d):
		mouseover_3d_changed.emit(mouseover_3d.duplicate())
		if mouseover_3d.obj:
			var shape_info2 = mouseover_3d.shape_info;
			if not shape_info2:
				var body = hit.collider;
				var vis_shape = body.vis_shape;
				assert(vis_shape);
				shape_info2 = {"body":body, "vis_shape":vis_shape};
			view.mouseover_gizmo.attach(shape_info2);
		else:
			view.mouseover_gizmo.detach();
