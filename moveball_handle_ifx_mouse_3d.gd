extends IfxMouse3D

var is_dragging = false;

func lmb_down(ray:Math.Ray):
	print("handle "+name+" got lmb_down at "+str(ray))
	is_dragging = true;
	return true;

func lmb_up(ray:Math.Ray):
	print("handle "+name+" got lmb_up at "+str(ray))
	is_dragging = false;
	return true;
	
func mouse_move(ray:Math.Ray, rel:Math.Ray):
	print("beep");
	return is_dragging;
