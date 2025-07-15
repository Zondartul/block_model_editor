extends DMItem
class_name DMItemProject

var bodies = []

func _init():
	serializer = Serializer.new();

class Serializer:
	extends DMItem.Serializer
	static func serialize(item:DMItem)->Dictionary:
		var project_item:DMItemProject = item;
		var json = {}
		json["type"] = 'project';
		var body_jsons = []
		for body in project_item.bodies:
			var body_item:DMItemBody = body;
			var body_json = body_item.serializer.serialize(body_item);
			body_jsons.append(body_json);
		json["children"] = body_jsons;
		return json;
		
	static func deserialize(json:Dictionary)->DMItem:
		var project_item:DMItemProject = DMItemProject.new();
		assert('children' in json);
		for body_json in json["children"]:
			var body:DMItemBody = DMItemBody.Serializer.deserialize(body_json);
			project_item.bodies.append(body);
		return project_item;
