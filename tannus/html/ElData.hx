package tannus.html;

import tannus.io.Getter;
import tannus.io.Ptr;
import tannus.html.Element;

import tannus.ds.Object;

abstract ElData (Getter<Element>) {
	/* Constructor Function */
	public inline function new(ref : Getter<Element>):Void {
		this = ref;
	}

/* === Instance Methods === */

	/* get a property */
	@:arrayAccess
	public inline function get<T>(key : String):Null<T> {
		return data.rawget( key );
	}

	/* set a property */
	@:arrayAccess
	public inline function set<T>(key:String, value:T):T {
		return untyped data.set(key, value);
	}

	/* check for existence of a property */
	public inline function exists(key : String):Bool {
		return (get(key) != null);
	}

	/* get a Pointer to a property of [this] */
	public inline function reference<T>(key : String):Ptr<T> {
		return untyped Ptr.create(self[ key ]);
	}

/* === Instance Fields === */

	/* the element */
	private var elem(get, never):Element;
	private inline function get_elem():Element return this.get();

	/* the data */
	private var data(get, never):Object;
	private inline function get_data():Object {
		return elem.data();
	}

	/* reference to [this] as an ElData instance */
	private var self(get, never):ElData;
	private inline function get_self():ElData {
		return new ElData( this );
	}
}
