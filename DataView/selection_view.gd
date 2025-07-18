extends Node
# Node: SelectionView

@export var vInput3D:Node;
#@onready var n_widget_moveball = $BC/BC_middle/BC_center/SubViewportContainer/SubViewport/Scene3D/widget_moveball
@export var n_widget_moveball:Node;

var selection_gizmo;

func _ready():
	selection_gizmo = vInput3D.script_gizmo_outline.new()
