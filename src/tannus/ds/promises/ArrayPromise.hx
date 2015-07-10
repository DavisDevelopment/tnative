package tannus.ds.promises;

import tannus.ds.Promise;

using Lambda;
class ArrayPromise<T> extends Promise<Array<T>> {
	
/* === Instance Methods === */

	/**
	  * Get an item in [this] Array
	  */
	public function get(index : Int):Promise<T> {
		var res:Promise<T> = Promise.create({
			then(function( items ) {
				return items[index];
			});

			unless(function( error ) {
				throw error;
			});
		});
		attach( res );
		return res;
	}

	/**
	  * Get a slice of [this] Array
	  */
	public function slice(pos:Int, ?end:Int):ArrayPromise<T> {
		return new ArrayPromise<T>(function(res, err) {
			then(function(list) {
				res(list.slice(pos, end));
			});

			unless(function(error) {
				err( error );
			});
		});
	}

	/**
	  * Concatenate [this] Array onto another one
	  */
	public function concat(other : Array<T>):ArrayPromise<T> {
		var res:ArrayPromise<T> = new ArrayPromise(function(res, err) {
			then(function(list) {
				res(list.concat(other));
			});

			unless(function(error) {
				err( error );
			});
		});
		attach( res );
		return res;
	}

	/**
	  * Map [this] Array
	  */
	public function map<A>(f : T->A):ArrayPromise<A> {
		var res:ArrayPromise<A> = fromPrim(transform(function(x) return x.map(f)));
		attach( res );
		return res;
	}

	/**
	  * Filter [this] Array
	  */
	public function filter(test : T->Bool):ArrayPromise<T> {
		var res:ArrayPromise<T> = fromPrim(transform(function(list) {
			return (list.filter(test));
		}));
		attach( res );
		return res;
	}

	/**
	  * Tells whether [this] Array has element [item]
	  */
	public function has(item : T):BoolPromise {
		var result:BoolPromise = new BoolPromise(function(res, err) {
			then(function( list ) {
				res(list.has( item ));
			});

			unless( err );
		});
		attach( result );
		return result;
	}

	/**
	  * Joins [this] Array together into a String
	  */
	public function join(sep : String):Promise<String> {
		var result:StringPromise = StringPromise.sp(yes, no, {
			then(function(list) yes(list.join(sep)));
			unless(no);
		});
		attach( result );
		return result;
	}

	/**
	  * Invokes [f] for every item in [list], when it is obtained
	  */
	public function each(f : T->Void):ArrayPromise<T> {
		then(function( list ) {
			for (item in list)
				f( item );
		});
		return this;
	}

	/**
	  * Create ArrayPromise<T> from Promise<Array<T>>
	  */
	public static inline function fromPrim<T>(pa : Promise<Array<T>>):ArrayPromise<T> {
		return new ArrayPromise(function(res, err) {
			pa.then(res);
			pa.unless(err);
		});
	}
}
