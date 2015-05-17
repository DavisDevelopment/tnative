package tannus.ds;

import tannus.io.Ptr;

using Lambda;
class ArrayTools {
	/**
	  * Obtain an Array of Pointers from an Array of values
	  */
	public static function pointerArray<T>(a : Array<T>):Array<Ptr<T>> {
		var res:Array<Ptr<T>> = new Array();
		for (i in 0...a.length) {
			res.push(Ptr.create(a[i]));
		}
		return res;
	}

	/**
	  * Obtain a copy of [list] with all instances of [blacklist] removed
	  */
	public static function without<T>(list:Array<T>, blacklist:Array<T>):Array<T> {
		var c = list.copy();
		for (v in blacklist) {
			while (true)
				if (!c.remove(v))
					break;
		}
		return c;
	}
}
