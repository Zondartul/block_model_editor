extends Node
# Node: Mouseover

@export var view:Node;
#@onready var camera = $BC/BC_middle/BC_center/SubViewportContainer/SubViewport/Scene3D/cam_anchor/Camera3D
@export var camera:Camera3D;
@export var cSelection:Node; #for get_shape_info_collider
@export var cData:Node; # for util/dicts_equal

#-------- 3D mouseover and clicking ---------
var mouseover_3d = {"obj":null, "sub_obj":null, "body_handle":null, "name":null, "pos":null};
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
		mouseover_3d.obj = hit.collider;
		var body_handle = cSelection.get_body_handle_from_collider(hit.collider)
		if body_handle:
			mouseover_3d.body_handle = body_handle;
		else:
			push_error("mouseover hit but no body handle");
	if not cData.dicts_equal(old_mouseover_3d, mouseover_3d):
		mouseover_3d_changed.emit(mouseover_3d.duplicate())
		if mouseover_3d.obj:
			var body_handle2 = mouseover_3d.body_handle;
		#	if not body_handle2: # -- bodies without a handle? Like a gizmo? no, gizmos should have handles.
		#		var body = hit.collider;
		#		var vis_shape = body.vis_shape;
		#		assert(vis_shape);
		#		body_handle2 = {"body":body, "vis_shape":vis_shape};
			if not body_handle2: return;
			view.mouseover_gizmo.attach(body_handle2);
		else:
			view.mouseover_gizmo.detach();
