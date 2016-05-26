package tannus.nore;

enum Token {
/* === Constructs === */
	TConst(c : Const);
	TOperator(op : String);
	TBrackets(tree : Array<Token>);
	TBoxBrackets(tree : Array<Token>);
	TGroup(tree : Array<Token>);
	TTuple(values : Array<Token>);
	TCall(id:String, args:Array<Token>);
	THelper(id:String, args:Array<Token>);
	TIf(test:Token, then:Token, ?otherwise:Token);

/* === Internal === */

	TComma;
	TOr;
	TNot;
	TApprox;
	TDoubleDot;
}

enum Const {
	CIdent(id : String);
	CString(s:String, quotes:Int);
	CReference(name : String);
	CNumber(n : Float);
}
