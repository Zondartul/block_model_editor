extends Node
class_name BodyHandle

var view_data = {
	"list_idx":0, # refers to SelectionView->shape_list
}
var viewport_nodes = { # nodes added to the scene3D that belong to this body
	"body": null,	
}
var body_item:DMItemBody; # refers to the item in the DataModel

func _init(new_body_item):
	body_item = new_body_item;

func get_gen():
	return body_item.generator.generator;
