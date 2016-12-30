package tannus.nore;

enum Check {
	// [type] or 'type' or 'pack.type'
	TypeCheck(t : String);

	// ~[type] or ~'type'
	LooseTypeCheck(t : String);

	// ..[type]
	ShortTypeCheck(t : String);
	NestedCheck(op:String, value:Value);

	FieldExistsCheck(name : String);
	FieldValueCheck(op:String, name:String, value:Value);
	FieldValueBlockCheck(name:String, checks:Array<Check>);
	FieldValueTypeCheck(name:String, type:String, loose:Bool);

	// :[helper name]
	HelperCheck(name:String, args:Array<Value>);

	GroupCheck(checks : Array<Check>);

	EitherCheck(left:Check, right:Check);
	InvertedCheck(check : Check);
	TernaryCheck(condition:Check, itrue:Check, ?ifalse:Check);
}
