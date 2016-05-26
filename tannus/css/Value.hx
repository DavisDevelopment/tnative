package tannus.css;

import tannus.graphics.Color;
import tannus.css.vals.Unit;

/**
  * Enum of all possible types of Property-values
  */
enum Value {
/* === Used Values === */

	/* Standard Identifier */
	VIdent(id : String);

	/* String */
	VString(str : String);

	/* Number */
	VNumber(num:Float, ?unit:Unit);

	/* Colors */
	VColor(col : Color);

	/* Variable Reference */
	VRef(name : String);

	/* Function Call */
	VCall(func:String, args:Array<Value>);

/* === Atomic Values (Not Used Directly) === */

	/* Tuple */
	VTuple(vals : Array<Value>);

	/* Comma */
	VComma;
}
