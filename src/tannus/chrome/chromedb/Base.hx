package tannus.chrome.chromedb;

import tannus.chrome.chromedb.BaseData in Data;
import tannus.storage.core.Database;
import tannus.storage.core.Table in Tabl;

import tannus.ds.AsyncStack;
import tannus.ds.Dict;
import tannus.ds.Object;
import tannus.ds.Promise;
import tannus.ds.promises.*;

import tannus.chrome.Storage.local in store;

class Base extends Database {
	/* Constructor Function */
	public function new(nam : String):Void {
		super();
		name = nam;
		data = new Data(name, new Map());
	}

/* === Instance Methods === */

	/**
	  * Reload [data]
	  */
	private function pull(cb : Void->Void) {
		store.get(name, function(o : Object) {
			if (o.exists(name)) {
				o = o[name];
				var enc:String = cast o;
				data.decode( enc );
				cb();
			} 
			else {
				sync(function() {
					cb();
				});
			}
		});
	}

	/**
	  * Persist changes to [data]
	  */
	private function sync(cb : Void->Void) {
		var o:Object = {};
		o[name] = data.encode();
		store.set(o, function() {
			cb();
		});
	}

	/**
	  * Obtain an Array of Table-Names
	  */
	override public function tableList():ArrayPromise<String> {
		return Promise.create({
			pull(function() {
				return data.tableList();
			});
		}).array();
	}

	/**
	  * Check for existence of a given Table
	  */
	override public function hasTable(name : String):BoolPromise {
		return Promise.create({
			pull(function() {
				return data.hasTable( name );
			});
		}).bool();
	}

	/**
	  * Delete a given Table
	  */
	override public function deleteTable(name : String):BoolPromise {
		return Promise.create({
			pull(function() {
				return data.deleteTable(name);
			});
		}).bool();
	}

	/**
	  * Obtain a reference to a Table
	  */
	override public function table(name : String):Promise<Tabl> {
		return Promise.create({
			pull(function() {
				return cast (new Table(name, this));
			});
		});
	}

	/**
	  * Create a new Table
	  */
	override public function createTable(name : String):Promise<Tabl> {
		return Promise.create({
			pull(function(){
				data.createTable( name );
				sync(function() {
					var res = table(name);
					res.then(function( t ) {
						return t;
					});
					res.unless(function( err ) {
						throw err;
					});
				});
			});
		});
	}

	/**
	  * Delete [this] Database
	  */
	public function delete():BoolPromise {
		return Promise.create({
			store.remove([name], function() {
				return true;
			});
		}).bool();
	}

/* === Instance Fields === */

	/* The local copy of [this] base */
	private var data : Data;
}
