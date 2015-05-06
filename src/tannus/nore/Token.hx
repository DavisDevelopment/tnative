package tannus.nore;

/**
  * Enumerator to Represent a Descriptor Token
  */
enum Token {
	//- Identifiers
	TIdent(ident : String);

	//- References - identifiers preceded by the @ symbol
	TRefence(id : Token);

	//- Strings
	TString(str : String);

	//- Numbers
	TNumber(num : Float);

	//- Operators
	TOperator(op : String);

	//- Group surrounded by Parentheses
	TGroup(subtree : Array<Token>);

	//- Tuple - A Comma-Separated structure to represent multiple values
	TTuple(values : Array<Array<Token>>);

	//- Call - An apparent invokation of a function
	TCall(id:String, args:Array<Array<Token>>);
	
	//- Asterisk (*)
	TAny;

	//- Colon (:)
	TColon;

	//- Question-Mark (?)
	TQuestion;

	//- Comma
	TComma;
	
	//- Box Brackets
	TOBracket;
	TCBracket;
	
	//- Parentheses
	TOParen;
	TCParen;

	//- HashTag
	THash;

	//- Array-Access
	TArrayAccess(index : Float);

	//- Range-Access
	TRangeAccess(start:Float, end:Float);
}
