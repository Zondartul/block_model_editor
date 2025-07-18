extends Node

#@onready var shape_list = $BC/BC_middle/BC_left/shape_list
@export var shape_list:Node;
@export var controller:Node;

func clear_shape_list():
	shape_list.clear();

func update_shape_list():
	shape_list.clear()
	for body_handle in controller.body_handles:
		var idx = shape_list.add_item(body_handle.body_item.name);
		body_handle.view_data["list_idx"] = idx
		print("dbg:add_item result: "+str(idx)) #verify that it returns index in Godot 4.4.1

func deselect_shape_list():
	shape_list.deselect_all();

func select_shape_list(idx:int):
	shape_list.select(idx);
