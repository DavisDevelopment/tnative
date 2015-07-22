package tannus.storage.core;

import tannus.ds.AsyncStack;
import tannus.ds.Promise;
import tannus.ds.promises.*;
import tannus.ds.Object;
import tannus.ds.Dict;
import tannus.ds.EitherType;

import tannus.storage.core.IndexInfo;
import tannus.storage.core.IndexType;
import tannus.storage.core.Query;

class Table {
	/* Constructor Function */
	public function new():Void {
		null;
	}

/* === Index-Related Instance Methods === */

	/**
	  * Obtain a list of all indices of [this] Table
	  */
	public function indexNames():ArrayPromise<String> {
		unimp();
		return Promise.create({
			throw 'Not Implemented!';
		}).array();
	}

	/**
	  * Obtain the info for all indices of [this] Table
	  */
	public function indexList():Promise<Dict<String, IndexInfo>> {
		return Promise.create({
			/* Promise of an Array of index names */
			var inames = indexNames();

			/* Dictionary of all index-info */
			var infos:Dict<String, IndexInfo> = new Dict();
			var stack:AsyncStack = new AsyncStack();

			function getInfo(name : String):Void {
				stack.push(function( next ) {
					indexInfo( name ).then(function( info ) {
						infos[name] = info;
						next();
					});
				});				
			}

			inames.then(function( names ) {
				for (n in names)
					getInfo( n );
				trace(stack);
				stack.run(function() {
					return infos;
				});
			});
		});
	}

	/**
	  * Determine whether the given index exists on [this] Table
	  */
	public function hasIndex(name : String):BoolPromise {
		unimp();
		return Promise.create({
			throw 'Not Implemented!';
		}).bool();
	}

	/**
	  * Create a new index on [this] Table
	  */
	public function createIndex(info : IndexInfo):BoolPromise {
		unimp();
		return Promise.create({
			throw 'Not Implemented!';
		}).bool();
	}

	/**
	  * Create a batch of indices all at once
	  */
	public function createIndexList(indices : Array<IndexInfo>):BoolPromise {
		unimp();
		return Promise.create({
			throw 'Not Implemented!';
		}).bool();
	}

	/**
	  * Drop an index from [this] Table
	  */
	public function deleteIndex(name : String):BoolPromise {
		unimp();
		return Promise.create({
			throw 'Not Implemented!';
		}).bool();
	}

	/**
	  * Obtain the info on a given Index of [this] Table
	  */
	public function indexInfo(name : String):Promise<IndexInfo> {
		unimp();
		return Promise.create({
			throw 'Not Implemented!';
		});
	}

/* === Row-Related Instance Methods === */

	/**
	  * Query some data from [this] Table
	  */
	public function get(?query : Object):Query {
		if (query == null)
			query = {};
		return new Query(query, this);
	}

	/**
	  * Obtain a Row by ID
	  */
	public function row(id : Dynamic):Promise<Row> {
		return Promise.create({
			indexList().then(function( indices ) {
				var pkey:Null<IndexInfo> = null;
				for (x in indices) {
					if (x.value.primary) {
						pkey = x.value;
						break;
					}
				}

				if (pkey == null) {
					throw 'TableError: Table has no primary key!';
				} else {
					var o:Object = {};
					o[pkey.name] = id;
					var prows = get( o ).fetch();
					prows.then(function( rows ) {
						return rows.shift();
					});
					prows.unless(function( err ) {
						throw err;
					});
				}
			});
		});
	}

	/**
	  * Insert a new Row onto [this] Table
	  */
	public function insert(data : Object):BoolPromise {
		unimp();
		return Promise.create({
			throw 'Not Implemented!';
		}).bool();
	}

	/**
	  * Insert an Array of Rows onto [this] Table
	  */
	public function inserts(rows : Array<Object>):BoolPromise {
		unimp();
		return Promise.create({
			throw 'Not Implemented!';
		}).bool();
	}

	/**
	  * Remove a Row from [this] Table
	  */
	public function delete(id : String):BoolPromise {
		unimp();
		return Promise.create({
			throw 'Not Implemented!';
		}).bool();
	}

	/**
	  * Update a Row
	  */
	public function update(id:String, changes:Object):BoolPromise {
		unimp();
		return Promise.create({
			throw 'Not Implemented!';
		}).bool();
	}

	/**
	  * Throw an error
	  */
	private inline function error(msg : String):Void {
		throw 'DatabaseTableError: $msg';
	}

	/**
	  * Report that the invoked method is not implemented
	  */
	private static macro function unimp() {
		return macro throw 'DatabaseTableError: Not Implemented!';
	}

/* === Instance Fields === */

	/* The name of [this] Table */
	public var name : String;
}

/* Placeholder type for a QueryPromise */
private typedef QProm = Promise<Query>;
