extends Node

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
		viewport_mouse_move(event.position, event.relative);

var navball_dragging = false;
@onready var n_cam_anchor = $BC/BC_middle/BC_center/SubViewportContainer/SubViewport/Scene3D/cam_anchor
# mouse position argument is unneeded now, but most mouse-based tools will use it.
func viewport_mmb_down(_pos:Vector2): navball_dragging = true;
func viewport_mmb_up(_pos:Vector2): navball_dragging = false;
func viewport_mouse_move(pos:Vector2, rel:Vector2):
	orbit_camera(rel);
	update_3d_mouseover(pos);
