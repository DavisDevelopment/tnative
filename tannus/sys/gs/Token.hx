package tannus.sys.gs;

/**
  * Enum of Tokens which can exist in a GlobStar
  */
enum Token {
/* === Expression-Level Constructs === */
	Literal(txt : String);
	Expand(pieces : Array<Tree>);
	Optional(sub : Tree);
	Param(name:String, check:Token);
	Star;
	DoubleStar;

/* === Meta-Constructs (these should never make it past tokenization === */

	Comma;
	Colon;
}

typedef Tree = Array<Token>;
