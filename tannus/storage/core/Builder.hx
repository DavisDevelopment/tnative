package tannus.storage.core;

import tannus.storage.core.Database;
import tannus.storage.core.Table;
import tannus.storage.core.IndexInfo;
import tannus.storage.core.TypeSystem.typeFromName;

import tannus.ds.AsyncStack;
import tannus.ds.Promise;
import tannus.ds.Object;
import Std.*;

class Builder {
	/* Constructor Function */
	public function new(data : DatabaseSpec):Void {
		spec = data;
	}

/* === Instance Methods === */

	/**
	  * Build out [this] Database
	  */
	public function build(db:Database, cb:Void->Void):Void {
		var stack = new AsyncStack();
		
		for (table in spec.tables) {
			stack.push(function(next) {
				buildTable(db, table, next);
			});
		}

		stack.run( cb );
	}

	/**
	  * Build out a given Table
	  */
	public function buildTable(db:Database, spec:TableSpec, cb:Void->Void):Void {
		var stack = new AsyncStack();
		var table:Null<Table> = null;

		/* Create the Table */
		stack.push(function(next) {
			var prom = db.createTable(spec.name);
			prom.then(function(t) {
				table = t;
				next();
			});
			prom.unless(function(err) {
				throw err;
			});
		});

		/* Build the Fields of [this] Table */
		for (key in spec.fields) {
			stack.push(function(next) {
				var index = table.createIndex(key);
				index.then(function(worked) {
					if (worked) {
						next();
					} else {
						throw 'BuilderError: Creation of Index "${key.name}" failed!';
					}
				});
				index.unless(function(err) {
					throw err;
				});
			});
		}

		stack.run( cb );
	}

	/**
	  * Rebuild [this] Database
	  */
	public function rebuild(db:Database, cb:Void->Void):Void {
		destroy(db, function() {
			build(db, cb);
		});
	}

	/**
	  * Destroy [this] Database
	  */
	public function destroy(db:Database, cb:Void->Void):Void {
		db.delete().then(function(status) {
			if (status)
				cb();
			else
				throw 'BuilderError: Deletion of database "${db.name}" failed!';
		}).unless(function(err) throw err);
	}

/* === Instance Fields === */

	private var spec : DatabaseSpec;

/* === Static Methods === */

	/**
	  * Create a Builder from JSON Data
	  */
	public static function fromJson(dat : Object):Builder {
		var spec:DatabaseSpec = {
			'name': string(dat['name']),
			'tables': []
		};

		var otables:Object = dat['tables'];
		var tabls:Array<TableSpec> = new Array();
		for (tabl in otables.pairs()) {
			var val:Object = tabl.value;
			var tspec:TableSpec = {
				'name': tabl.name,
				'fields': []
			};
			for (f in val.pairs()) {
				var key:Object = f.value;
				tspec.fields.push(new IndexInfo( 
					(f.name),
					(f.value.type),
					(key['primary'].or(false)),
					(key['required'].or(false)),
					(key['unique'].or(false)),
					(key['auto'].or(false))
				));
			}
			tabls.push( tspec );
		}
		spec.tables = tabls;

		return new Builder( spec );
	}
}

typedef DatabaseSpec = {
	var name : String;
	var tables : Array<TableSpec>;
};

typedef TableSpec = {
	var name : String;
	var fields : Array<IndexInfo>;
};
