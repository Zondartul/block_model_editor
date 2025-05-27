extends Node

class Ray:
	var orig:Vector3
	var dir:Vector3
	func _to_string()->String:
		return str(orig)+"->"+str(dir);

static func line_to_line_closest_point(ray_A:Ray, ray_B:Ray):	
	var P0 = ray_A.orig;
	var w0 = ray_B.orig - ray_A.orig;
	var u = ray_A.dir;
	var v = ray_B.dir;
	var pt = P0 + ((v.dot(u))*(w0.dot(v) - (v.dot(v))*(w0.dot(u)))/((u.dot(u))*(v.dot(v))-(v.dot(u))**2))*u;
	return pt;
