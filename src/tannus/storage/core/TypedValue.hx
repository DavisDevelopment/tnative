package tannus.storage.core;

import tannus.io.ByteArray;
import tannus.ds.Dict;

enum TypedValue {
	/* ITFloat */
	TVFloat(num : Float);

	/* ITInt */
	TVInt(num : Int);

	/* ITBool */
	TVBool(v : Bool);

	/* ITString */
	TVString(str : String);

	/* ITBytes */
	TVBytes(v : ByteArray);

	/* ITDate */
	TVDate(date : Date);

	/* ITArray */
	TVArray(v : Array<TypedValue>);

	/* ITDict */
	TVDict(v : Dict<String, TypedValue>);
}
