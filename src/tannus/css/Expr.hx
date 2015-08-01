package tannus.css;

import tannus.css.Value;

/**
  * Enum of all CSS-Expressions understood by [this] System
  */
enum Expr {
	/* CSS Rule */
	ERule(sel:String, content:Array<Expr>);

	/* CSS Property-Definition */
	EProp(name:String, values:Array<Value>);
}
