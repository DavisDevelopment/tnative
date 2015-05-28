package tannus.ds;

class Memory {
	public static var state:Int = 0;

	/**
	  * Obtain a unique integer
	  */
	public static function uniqueIdInt():Int {
		var id = state;
		state++;
		return id;
	}

	/**
	  * Obtain a unique String
	  */
	public static function uniqueIdString(prefix:String=''):String {
		return (prefix + uniqueIdInt());
	}
}
