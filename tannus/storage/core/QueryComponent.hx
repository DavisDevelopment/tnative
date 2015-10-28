package tannus.storage.core;

import tannus.ds.Object;
import tannus.storage.core.TypeSystem in Ts;
import tannus.storage.core.TypedValue in Val;

/**
  * Enum of possible steps which can be taken on a Query
  */
enum QueryComponent {

/* === Specifying Which Rows are Desired === */
	
	/* Get an Array of Rows by an Array of IDs */
	QCIdList(ids : Array<String>);

	/* Get an Array of Rows by Checking for strict  */
	QCFieldValue(key:String, value:Dynamic, op:QCBoolOp);
	QCFieldValueList(checks : Array<{key:String, value:Dynamic, op:QCBoolOp}>);

/* === Manipulating the fetched data === */

	/* Specify a subset of indices to give retrieved Rows */
	QCPluck(indices : Array<String>);

	/* Specify indices to omit from retrieved Rows */
	QCWithout(indices : Array<String>);

/* === Filtering The Fetched Data === */

	/* Return only the Rows for which [predicate] returns true */
	QCFilter(predicate : Object->Bool);
}

/**
  * Enum of boolean operators
  */
@:enum
abstract QCBoolOp (String) {

/* === Constructs === */

	/* Equals */
	var Eq = 'eq';

	/* Doesn't Equal */
	var Ne = 'ne';

	/* Greater Than */
	var Gt = 'gt';

	/* Less Than */
	var Lt = 'lt';

	/* Greater Than or Equal To */
	var Ge = 'ge';

	/* Less Than or Equal To */
	var Le = 'le';

	/* Value in Array */
	var In = 'in';

	/* Array has Value */
	var Has = 'has';

/* === Methods === */

	/**
	  * Obtain a QCBoolOp value from a String
	  */
	@:from
	public static function fromString(str : String):QCBoolOp {
		switch (str.toLowerCase()) {
			/* Equal To */
			case 'eq' | '==':
				return Eq;

			/* Not Equal To */
			case 'ne' | '!=':
				return Ne;

			/* Greater Than */
			case 'gt' | '>':
				return Gt;

			/* Greater Than or Equal To */
			case 'ge' | '>=':
				return Ge;

			/* Less Than */
			case 'lt' | '<':
				return Lt;

			/* Less Than or Equal To */
			case 'le' | '<=':
				return Le;

			case 'in':
				return In;

			case 'has' | 'contains':
				return Has;

			/* Anything Else */
			default:
				throw 'Cannot create a QCBoolOp value from "$str"!';
		}
	}

	/**
	  * Get comparison functoin 
	  */
	public static function toFunction(op : QCBoolOp):Val->Val->Bool {
		return (switch (op) {
			case Eq: Ts.eq;
			case Ne: Ts.ne;
			case Gt: Ts.gt;
			case Ge: Ts.ge;
			case Lt: Ts.lt;
			case Le: Ts.le;
			case In: Ts.vin;
			case Has: Ts.has;
		});
	}
}
