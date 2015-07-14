package tannus.chrome.chromedb;

import tannus.chrome.chromedb.Base;
import tannus.chrome.chromedb.BaseData.TableData;

import tannus.storage.core.Table in Tabl;
import tannus.storage.core.IndexInfo;
import tannus.storage.core.TypeSystem in Ts;
import tannus.storage.core.Row;

import tannus.ds.AsyncStack;
import tannus.ds.Dict;
import tannus.ds.Object;
import tannus.ds.Promise;
import tannus.ds.promises.*;

using Lambda;
using tannus.ds.ArrayTools;

@:access(tannus.chrome.chromedb.Base)
class Table extends Tabl {
	/* Constructor Function */
	public function new(nam:String, base:Base):Void {
		super();
		name = nam;
		db = base;
		data = db.data.table( name );
	}

/* === Instance Methods === */

	/**
	  * Reload underlying data
	  */
	private function pull(cb : Void->Void) {
		db.pull(function() {
			data = db.data.table( name );
			cb();
		});
	}

	/**
	  * Persist underlying data
	  */
	private function sync(cb : Void->Void) {
		db.sync( cb );
	}

/* === Row-Related Instance Methods ==== */

	/**
	  * Query some rows from [this] Table
	  */
	override public function get(?q : Object):Query {
		if (q == null)
			q = {};
		return new Query(q, cast this);
	}

	/**
	  * Get a row by id
	  */
	override public function row(id : String):Promise<Row> {
		return Promise.create({
			pull(function() {
				var res:Null<Object> = data.get(id);
				if (res == null)
					throw 'Row "$id" does not exist';
				else {
					tannus.storage.core.RowData.create(cast this, res, function( rd ) {
						return new Row(cast this, rd);
					});
				}
			});
		});
	}

	/**
	  * Insert some rows onto [this] Table
	  */
	override public function insert(row : Object):BoolPromise {
		return Promise.create({
			pull(function() {
				var id:String = data.primary();
				data.insert( row );
				sync(function() {
					return true;
				});
			});
		}).bool();
	}

	/**
	  * Insert a list of rows
	  */
	override public function inserts(rows : Array<Object>):BoolPromise {
		return Promise.create({
			pull(function() {
				var id:String = data.primary();
				for (row in rows)
					data.insert( row );
				sync(function() {
					return true;
				});
			});
		}).bool();
	}

	/**
	  * Delete a Row by id
	  */
	override public function delete(id : String):BoolPromise {
		return Promise.create({
			pull(function() {
				var res:Bool = data.delete( id );
				sync(function() {
					return res;
				});
			});
		}).bool();
	}

	/**
	  * Update a Row
	  */
	override public function update(id:String, changes:Object):BoolPromise {
		return Promise.create({
			pull(function() {
				var row = data.get(id);
				if (row != null) {
					var keys:Array<String> = changes.keys.union(row.keys);
					var failed:Bool = false;
					for (k in keys) {
						var ov:Dynamic = row[k].value;
						var nv:Dynamic = changes[k].value;
						if (Ts.validate(nv, data.indexInfo(k).type)) {
							row[k] = nv;
						}
						else {
							failed = true;
							throw 'Invalid value for field "$k"';
						}
					}
					sync(function() {
						return !failed;
					});
				}
				else {
					throw 'Cannot update non-existent Row';
				}
			});
		}).bool();
	}

/* === Index-Related Instance Methods === */

	/**
	  * Obtain an Array of all index names
	  */
	override public function indexNames():ArrayPromise<String> {
		return Promise.create({
			pull(function() {
				return data.indexNames();
			});
		}).array();
	}

	/**
	  * Obtain data on a given index
	  */
	override public function indexInfo(iname : String):Promise<IndexInfo> {
		return Promise.create({
			pull(function() {
				return data.indexInfo(iname);
			});
		});
	}

	/**
	  * Check for existence of a given index
	  */
	override public function hasIndex(iname : String):BoolPromise {
		return Promise.create({
			pull(function() {
				return data.hasIndex( iname );
			});
		}).bool();
	}

	/**
	  * Add a new Index to [this] Table
	  */
	override public function createIndex(info : IndexInfo):BoolPromise {
		return Promise.create({
			pull(function() {
				data.createIndex( info );
				sync(function() {
					return true;
				});
			});
		}).bool();
	}

	/**
	  * Add an Array of indices
	  */
	override public function createIndexList(indexes : Array<IndexInfo>):BoolPromise {
		return Promise.create({
			pull(function() {
				for (info in indexes)
					data.createIndex( info );
				sync(function() {
					return true;
				});
			});
		}).bool();
	}

	/**
	  * Delete an Index
	  */
	override public function deleteIndex(iname : String):BoolPromise {
		return Promise.create({
			pull(function() {
				return data.deleteIndex( iname );
			});
		}).bool();
	}

/* === Instance Fields === */

	public var db : Base;
	private var data : TableData;
}
