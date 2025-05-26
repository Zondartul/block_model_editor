extends Node
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
