extends Node
# Node: DataModel

# Project: Block Model Editor
# MVC - Model
# (the former is Model as in Mesh, the latter is Model in MVC sense)
#
# Contains persistent project data,
# such as the edited object and its properties.
# Mesh exports are extracted from this data
# Mesh imports populate this data

const class_DMItem = preload("res://DataModel/DMItem.gd");
const class_DMItemBody = preload("res://DataModel/DMItemBody.gd");

var project;

func _ready():
	new_project();

func new_project():
	project = DMItemProject.new();
	add_child(project);

func deserialize_project(json_str:String):
	var json = JSON.parse_string(json_str);
	assert(json);
	assert('type' in json);
	assert(json['type'] == "project")
	project = DMItemProject.Serializer.new().deserialize(json);

func serialize_project()->String:
	return project.serializer.serialize(project);

func add_body(body_item:DMItemBody):
	project.add_child(body_item);
	
