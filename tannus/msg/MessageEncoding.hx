package tannus.msg;

@:enum
abstract MessageEncoding (String) from String to String {
	var StructuredClone = 'sc';
	var Json = 'json';
	var HaxeSerialization = 'hx';
}
