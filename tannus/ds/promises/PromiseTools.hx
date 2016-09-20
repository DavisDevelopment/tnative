package tannus.ds.promises;

import tannus.ds.*;
import tannus.ds.AsyncPool;

using Lambda;
using tannus.ds.ArrayTools;

class PromiseTools {
	/**
	  * perform a batch promise operation, transforming a Array<Promise<T>> into a Promise<Array<T>>
	  */
	public static function batch<T>(promises : Array<Promise<T>>):ArrayPromise<T> {
		return Promise.create({
			var pool = new AsyncPool();
			for (p in promises) {
				pool.push(function(index, done) {
					p.then(function(result) {
						done(null, result);
					});
					p.unless(function(error) {
						done(error, null);
					});
				});
			}
			pool.run(function(results) {
				return results.macmap( _.value );
			});
		}).array();
	}
}
