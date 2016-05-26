package tannus.nore;

enum Check {
	TypeCheck(t : String);
	LooseTypeCheck(t : String);
	ShortTypeCheck(t : String);
	NestedCheck(op:String, value:Value);

	FieldExistsCheck(name : String);
	FieldValueCheck(op:String, name:String, value:Value);
	FieldValueBlockCheck(name:String, checks:Array<Check>);
	FieldValueTypeCheck(name:String, type:String, loose:Bool);

	HelperCheck(name:String, args:Array<Value>);

	GroupCheck(checks : Array<Check>);

	EitherCheck(left:Check, right:Check);
	InvertedCheck(check : Check);
	TernaryCheck(condition:Check, itrue:Check, ?ifalse:Check);
}
