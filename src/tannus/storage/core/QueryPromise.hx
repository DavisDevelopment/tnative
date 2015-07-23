package tannus.storage.core;

import tannus.storage.core.Table;
import tannus.storage.core.Query;
import tannus.storage.core.Row;

import tannus.ds.Object;
import tannus.ds.Promise;
import tannus.ds.promises.ArrayPromise;

class QueryPromise extends Promise<Query> {
/* === Instance Fields === */

	/**
	  * Add a WHERE clause to [this] Query
	  */
	public function where(key:String, value:Dynamic, ?op:String):QueryPromise {
		then(function(q) {
			q.where(key, value, op);
		});
		return this;
	}

	/**
	  * Add a FILTER clause to [this] Query
	  */
	public function filter(pred : Row->Bool):QueryPromise {
		then(function(q) q.filter(pred));
		return this;
	}

	/**
	  * Add a PLUCK clause to [this] Query
	  */
	public function pluck(keys : Array<String>):QueryPromise {
		then(function(q) q.pluck(keys));
		return this;
	}

	/**
	  * Add a WITHOUT clause to [this] Query
	  */
	public function without(keys : Array<String>):QueryPromise {
		then(function(q) q.without(keys));
		return this;
	}

	/**
	  * Fetch the results of [this] Query
	  */
	public function fetch():ArrayPromise<Row> {
		return Promise.create({
			then(function(q) {
				q.fetch()
					.then(function(rows) return rows)
					.unless(function(err) throw err);
			});
			unless(function(err) {
				throw err;
			});
		}).array();
	}
}
