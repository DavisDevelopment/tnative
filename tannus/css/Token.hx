package tannus.css;

import tannus.css.Value;

enum Token {
	TRule(selector:String, props:Array<Token>);
	TProp(name:String, value:Val);
	TMixin(name : String);
	TVar(name:String, value:Val);
}

typedef Val = Array<Value>;
