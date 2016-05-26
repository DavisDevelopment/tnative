package tannus.nore;

enum Value {
	VString(str : String);
	VNumber(num : Float);
	VArray(values : Array<Value>);
	VField(name : String);
}
