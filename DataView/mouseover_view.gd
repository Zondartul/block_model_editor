extends Node
# Node: MouseoverView

@export var vInput3D:Node;

var mouseover_gizmo;

func _ready():
	mouseover_gizmo = vInput3D.script_gizmo_outline.new()
	mouseover_gizmo.thickness = 1.1;
