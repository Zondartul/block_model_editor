extends Node
# Node: Input3D

#signal shape_click;
#signal void_click;

@export var cData:Node;

@onready var cCam3D = $CamControl3D
@onready var cMouseover = $Mouseover

func _on_sub_viewport_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			match event.button_index:
				MOUSE_BUTTON_LEFT: viewport_click(event.position);
				MOUSE_BUTTON_MIDDLE: cCam3D.viewport_mmb_down(event.position);
				MOUSE_BUTTON_WHEEL_DOWN: cCam3D.viewport_mwheel_down(event.position);
				MOUSE_BUTTON_WHEEL_UP: cCam3D.viewport_mwheel_up(event.position);
				_: pass; # ignore other buttons
		else:
			match event.button_index:
				MOUSE_BUTTON_MIDDLE: cCam3D.viewport_mmb_up(event.position);
				_: pass; # ignore other buttons		
	elif event is InputEventMouseMotion:
		viewport_mouse_move(event.position, event.relative);

func viewport_click(mouse_pos:Vector2):
	print("Mouse clicked at: ", mouse_pos)
	cMouseover.update_3d_mouseover(mouse_pos);
	if cMouseover.mouseover_3d.shape_info: cData.shape_click(cMouseover.mouseover_3d.shape_info);
	else: cData.void_click();

func viewport_mouse_move(pos:Vector2, rel:Vector2):
	cCam3D.orbit_camera(rel);
	cMouseover.update_3d_mouseover(pos);
