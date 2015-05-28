package tannus.css;

class Property {
	/* Constructor Function */
	public function new(key:String, val:String):Void {
		name = key;
		value = val;
	}

/* === Instance Fields === */

	public var name : String;
	public var value : String;
}
