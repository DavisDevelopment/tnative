package tannus.nore;

/**
  * Enum to represent value-retrieval types in ORegEx grammar
  */ 
enum Value {
	//- Literal Number
	VNumber(num : Float);
	
	//- Literal String
	VString(str : String);

	//- Reference to a field
	VFieldReference(field : String);

	//- Reference to an index
	VIndexReference(index : Int);

	//- Reference to an index of a field
	VArrayAccess(field:String, index:Int);

	//- Tuple of Values
	VTuple(vals : Array<Value>);
}
