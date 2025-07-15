extends Node

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
