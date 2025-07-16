extends DMItem
class_name DMItemBody

var generator; # API to create render and collision shapes, if applicable
var color;

func _init(_shape_type:String, _generator_data=null):
	serializer = Serializer.new()
	generator = Generator.new(_shape_type, _generator_data);

class Generator:
	const shape_types = ['box', 'cylinder', 'sphere'];
	var shape_type;
	var generator:ShapeGenerator;
	var generator_data;
	func _init(_shape_type:String, _generator_data=null):
		shape_type = _shape_type
		generator_data = _generator_data;
		assert(shape_type in shape_types);
		match shape_type:
			'box': generator = ShapeGenBox.new()
			'cylinder': generator = ShapeGenCylinder.new()
			'sphere': generator = ShapeGenSphere.new()

class Serializer:
	extends DMItem.Serializer;
	func serialize(item:DMItem)->Dictionary:
		var json = {};
		json["type"] = "body";
		assert(item.generator is Generator);
		var gen:Generator = item.generator;
		json["shape"] = gen.shape;
		json["shape_data"] = gen.generator_data;
		json["color"] = gen.generator_data["color"];
		return json;
		
	func deserialize(json:Dictionary)->DMItem:
		var dmi = DMItem.new()
		dmi.type = "body";
		for prop in ['shape', 'shape_data', 'color']:
			assert(prop in json);
		var gen = Generator.new(json["shape"], json["shape_data"]);
		gen.generator_data["color"] = json["color"];
		dmi.generator = gen;
		return dmi;
