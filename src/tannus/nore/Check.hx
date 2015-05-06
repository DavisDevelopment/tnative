package tannus.nore;

import tannus.nore.Value;

enum Check {
	//- "Check" that will match anything
	NoCheck;

	//- Check for verifying that an Entity has a particular ID
	IDCheck(id : Value);

	//- Verify that an Entity is of a given type
	TypeCheck(typename : String);

	//- Check for the existence of [field]
	FieldExistsCheck(field : String);

	//- Check that the result of [op] applied to [field] and [value] is [true]
	FieldValueCheck(field:String, op:String, value:Value);

	//- Check a list of Checks
	GroupCheck(subchecks : Array<Check>);

	//- Check that the helper function [helper] validates
	HelperCheck(helper:String, ?args:Array<Value>);

	//- Check that represents a List of possible values
	//- NOTE: This Check is one that will never reach compilation, as it is only used in conjunction with other Checks
	TupleCheck(tup : Array<Value>);

	//- Check that [check] fails
	InverseCheck(check : Check);

	//- Check ther EITHER [left] or [right] succeeds
	EitherCheck(left:Check, right:Check);

	/**
	  * Ternary Check
	  *---------------
	  * If [condition] validates, attempt to validate [ifTrue], otherwise attempt to validate [ifFalse]
	  */
	TernaryCheck(condition:Check, ifTrue:Check, ifFalse:Check);
}
