extends Node3D
class_name DMItem

signal DM_changed; #params: (item(self), property(ref), property_path(string))
					# property path like item/generator/generator_data/size/x
signal DM_view_changed; # view needs updating, but model is still the same.

const types = ['project', 'body'];
var type; # one of ['body']
var serializer:Serializer; # API to serialize and deserialize
#var children; # attached items

class Serializer:
	func serialize(_item:DMItem)->Dictionary: return {}; #takes DMItem, returns string
	func deserialize(_json:Dictionary)->DMItem: return DMItem.new(); #takes string, returns DMItem
	# These functions are non-static because GDScript cannot override static functions in sub-classes

func _set(property: StringName, value: Variant) -> bool:
		if not property in self: return false;
		self[property] = value;
		var path = NodePath(":"+property)
		DM_changed.emit(name, path);
		print("DM_changed: "+name+", "+path);
		return true;
