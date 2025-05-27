extends Node
class_name IfxMouse3D

# abstract interface for 3D interactions with mouse
# these functions are clicked when user does a mouse interaction with the viewport.

# left mouse button pressed
func lmb_down(ray:Math.Ray): pass
func lmb_up(ray:Math.Ray): pass

# right mouse button
func rmb_down(ray:Math.Ray): pass
func rmb_up(ray:Math.Ray): pass

# middle mouse button
func mmb_down(ray:Math.Ray): pass
func mmb_up(ray:Math.Ray): pass

# mouse wheel
func mw_down(ray:Math.Ray): pass
func mw_up(ray:Math.Ray): pass

# mouse motion
func mouse_move(ray:Math.Ray, rel:Math.Ray): pass

# general event handling
# event - normal godot InputEvent
# ray - 3D ray from camera corresponding to mouse position
# rel - difference from previous frame's ray (only for moving mouse)
func on_event(event:InputEvent, ray:Math.Ray, rel:Math.Ray)->bool:
	var is_handled = false;
	if event is InputEventMouseButton:
		if event.pressed:
			match event.button_index:
				MOUSE_BUTTON_LEFT: is_handled = lmb_down(ray);
				MOUSE_BUTTON_RIGHT: is_handled = rmb_down(ray);
				MOUSE_BUTTON_MIDDLE: is_handled = mmb_down(ray);
				_: pass; # ignore others
		else:
			match event.button_index:
				MOUSE_BUTTON_LEFT: is_handled = lmb_up(ray);
				MOUSE_BUTTON_RIGHT: is_handled = rmb_up(ray);
				MOUSE_BUTTON_MIDDLE: is_handled = mmb_up(ray);
				_: pass; # ignore others
	elif event is InputEventMouseMotion:
		is_handled = mouse_move(ray, rel);
	else:
		pass; # ignore others
	if not is_handled: is_handled = false;
	return is_handled;
