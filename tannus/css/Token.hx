package tannus.css;

enum Token {
/* === Tokens === */

	/* Identifier */
	TIdent(s : String);

	/* Variable Reference */
	TRef(s : String);

	/* Block */
	TBlock(tree : Array<Token>);

	/* Group */
	TParen(tree : Array<Token>);

	/* Semicolon */
	TSemi;

	/* Colon */
	TColon;

	/* Comma */
	TComma;
}
