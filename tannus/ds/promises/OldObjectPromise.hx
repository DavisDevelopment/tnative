package tannus.ds.promises;

import tannus.ds.Promise;
import tannus.ds.promises.BoolPromise in Bp;
import tannus.ds.promises.ArrayPromise in Ap;
import tannus.ds.Object;

import Std.is;

class ObjectPromise extends Promise<Object> {
/* === Instance Methods === */

	/**
	  * Check for existence of a certain field
	  */
	public function exists(key : String):BoolPromise {
		var r = new Bp(function(res, err) {
			then(function( o ) res(o.exists(key)));
			unless( err );
		});
		attach( r );
		return r;
	}

	/**
	  * Obtain a List of all keys of [this] Object
	  */
	public function keys():ArrayPromise<String> {
		var r = new Ap(function(a, e) {
			then(function(o) a(o.keys));
			unless(e);
		});
		attach( r );
		return r;
	}

	/**
	  * Get the value of field [key]
	  */
	public function get(key : String):ObjectPromise {
		var r = new ObjectPromise(function(accept, reject) {
			/* When [this] Promise is fulfilled */
			then(function(o : Object) {
				trace( o );
				//- return the value of [o]'s [key] field
				accept( o[key].value );
			});

			/* When [this] Promise encounters an error */
			unless( reject );
		});

		attach( r );

		return r;
	}
}
