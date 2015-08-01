package tannus.css;

/**
  * Enum of tokens in a CSS Token-Tree
  */
enum Token {
	/* Selector Token */
	TSel(s : String);
	TBlock(tree : Array<Token>);
	TProp(name:String, value:String);
	TVar(name:String, value:String);
	TEof;
}
