extends Node
class_name DMItem

const types = ['project', 'body'];
var type; # one of ['body']
var serializer:Serializer; # API to serialize and deserialize
var children; # attached items

class Serializer:
	func serialize(_item:DMItem)->Dictionary: return {}; #takes DMItem, returns string
	func deserialize(_json:Dictionary)->DMItem: return DMItem.new(); #takes string, returns DMItem
	# These functions are non-static because GDScript cannot override static functions in sub-classes
