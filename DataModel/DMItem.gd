extends Node
class_name DMItem

const types = ['project', 'body'];
var type; # one of ['body']
var serializer:Serializer; # API to serialize and deserialize
var children; # attached items

class Serializer:
	static func serialize(item:DMItem)->Dictionary: return {}; #takes DMItem, returns string
	static func deserialize(json:Dictionary)->DMItem: return DMItem.new(); #takes string, returns DMItem
