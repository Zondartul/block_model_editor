extends Node
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

func deserialize_project(str:String):
	var json = JSON.parse_string(str);
	assert(json);
	assert('type' in json);
	assert(json['type'] == "project")
	project = DMItemProject.Serializer.deserialize(json);

func serialize_project()->String:
	return project.serializer.serialize(project);
