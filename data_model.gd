extends Node
# Project: Block Model Editor
# MVC - Model
# (the former is Model as in Mesh, the latter is Model in MVC sense)
#
# Contains persistent project data,
# such as the edited object and its properties.
# Mesh exports are extracted from this data
# Mesh imports populate this data

var bodies = [];

class DMSerializer:
	func serialize(item:DMItem)->Dictionary: return {}; #takes DMItem, returns string
	func deserialize(json:Dictionary)->DMItem: return DMItem.new(); #takes string, returns DMItem

class DM_Body_Generator:
	const shape_types = ['box', 'cylinder', 'sphere'];
	var shape_type;
	var generator:ShapeGenerator;
	var generator_data;
	func _init(_shape_type, _generator_data=null):
		shape_type = _shape_type
		generator_data = _generator_data;
		assert(shape_type in shape_types);
		match shape_type:
			'box': generator = ShapeGenBox.new()
			'cylinder': generator = ShapeGenCylinder.new()
			'sphere': generator = ShapeGenSphere.new()

class DMItem:
	const types = ['body'];
	var type; # one of ['body']
	var data; # arbitrary implementation data
	var serializer; # API to serialize and deserialize
	var generator; # API to create render and collision shapes, if applicable
	var children; # attached items

class DM_Body_serializer:
	extends DMSerializer;
	func serialize(item:DMItem)->Dictionary:
		var json = {};
		json["type"] = "body";
		assert(item.generator is DM_Body_Generator);
		var gen:DM_Body_Generator = item.generator;
		json["shape"] = gen.shape;
		json["shape_data"] = gen.generator_data;
		json["color"] = gen.generator_data["color"];
		return json;
		
	func deserialize(json:Dictionary)->DMItem:
		var dmi = DMItem.new()
		dmi.type = "body";
		for prop in ['shape', 'shape_data', 'color']:
			assert(prop in json);
		var gen = DM_Body_Generator.new(json["shape"], json["shape_data"]);
		gen.generator_data["color"] = json["color"];
		dmi.generator = gen;
		return dmi;

func deserialize(str:String):
	var json = JSON.parse_string(str);
	assert(json);
	assert('type' in json);
	if json['type'] == "body":
		var serdes = DM_Body_serializer.new()
		var item:DMItem = serdes.deserialize(json);
		return item; # should be appended to item list and also we should iter over the list
