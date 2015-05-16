package tannus.ds;

import tannus.io.Ptr;

class ArrayTools {
	public static function pointerArray<T>(a : Array<T>):Array<Ptr<T>> {
		var res:Array<Ptr<T>> = new Array();
		for (i in 0...a.length) {
			res.push(Ptr.create(a[i]));
		}
		return res;
	}
}
