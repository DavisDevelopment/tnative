package tannus.storage.db;

import tannus.storage.Storage;
import tannus.storage.SubStorage;
import tannus.mvc.Model;

import tannus.ds.Object;
import tannus.ds.Obj;
import tannus.ds.AsyncStack;

import Std.*;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;
using tannus.macro.MacroTools;

class Table extends Model {
	/* Constructor Function */
	public function new(s : Storage):Void {
		super();
		storage = s;

		onready( initialize );
	}

/* === Instance Methods === */

	/**
	  * initialize [this] Table
	  */
	private function initialize():Void {
		key = get( 'key' );
		autoIncrement = get( 'autoIncrement' );
		indices = cast(get('indices'), String).split( ',' );
	}

	/**
	  * Add a new Index to [this] Table
	  */
	public function createIndex(index:Index, ?cb:Void->Void):Void {
		var nlist = indices;
		if (!nlist.has( index.name )) {
			nlist.push( index.name );
			set('indices', nlist.join(','));
			set(ik(index.name), index);
			sync(function() {
				indices = cast(get('indices'), String).split( ',' );
				if (cb != null) {
					cb();
				}
			});
		}
		else {
			throw 'StorageError: Index ${index.name} already defined';
		}
	}

	/**
	  * get the data on the given Index
	  */
	public inline function getIndex(name : String):Index {
		return get(ik( name ));
	}

	/* check for existence of the given Index */
	public inline function hasIndex(name : String):Bool {
		return exists(ik( name ));
	}

	/**
	  * delete the given Index from [this] Table
	  */
	public function deleteIndex(name:String, ?cb:Void->Void):Void {
		indices.remove( name );
		saveIndices();
		remove(ik( name ));
		sync(function() {
			if (cb != null) {
				cb();
			}
		});
	}

	/**
	  * get an Array containing the keys of every row in [this] Table
	  */
	public function rowKeys():Array<String> {
		return string((exists( 'rows' ) ? get( 'rows' ) : '')).split(',');
	}

	/**
	  * get the row specified by [id]
	  */
	public function getRow(key : String):Null<Row> {
		if (rowKeys().has( key )) {
			var row:Obj = {};
			row[this.key] = key;
			for (index in indices) {
				row[index] = get(rik(key, index));
			}
			return new Row(this, row);
		}
		else {
			return null;
		}
	}

	/**
	  * Get all Rows on [this] Table
	  */
	public function getAllRows():Array<Row> {
		return [for (id in rowKeys()) getRow( id )];
		/*
		var all:Array<Row> = new Array();
		var ids = rowKeys();
		for (id in ids) {
			all.push(getRow( id ));
		}
		return all;
		*/
	}

	/**
	  * update an existing row with [data]
	  */
	public function updateRow(key:String, data:Obj, ?cb:Void->Void):Void {
		if (rowKeys().has( key )) {
			for (index in indices) {
				if (data.exists( index )) {
					set(rik(key, index), data[index]);
				}
			}

			sync(function() {
				if (cb != null) {
					cb();
				}
			});
		}
	}

	/**
	  * add a new Row
	  */
	public function addRow(data:Obj, ?cb:Row -> Void):Void {
		var props = [key].concat( indices );
		if ( autoIncrement ) {
			data.remove( key );
			var rkeys = rowKeys();
			if (rkeys.length > 0) {
				var maxk:Int = rkeys.map( parseInt ).macmax( _ );
				maxk = (maxk == null ? -1 : maxk);
				data[key] = string( ++maxk );
			}
			else {
				data[key] = '0';
			}
		}
		else {
			if (!data.exists( key )) {
				throw 'StorageError: missing column $key';
			}
		}

		var rkey:String = string(data[key]);
		var ids = (rowKeys().concat([ rkey ])).macfilter(!_.empty());
		set('rows', ids.join(','));
		updateRow(rkey, data, function() {
			if (cb != null) {
				cb(getRow( rkey ));
			}
		});
	}

	/**
	  * delete a row
	  */
	public function deleteRow(key:String, ?cb:Void->Void):Void {
		var rl = rowKeys();
		rl.remove( key );
		set('rows', rl.join(','));
		for (index in indices) {
			remove(rik(key, index));
		}
		sync(function() {
			if (cb != null) {
				cb();
			}
		});
	}

	/**
	  * Delete all data stored in [this] Table
	  */
	public function clear(?cb : Void -> Void):Void {
		var stack = new tannus.ds.AsyncStack();
		for (id in rowKeys()) {
			stack.push(deleteRow.bind(id, _));
		}
		for (index in indices) {
			stack.push(deleteIndex.bind(index, _));
		}
		stack.run(function() {
			if (cb != null) {
				cb();
			}
		});
	}

	/**
	  * persist the 'indices' field
	  */
	private function saveIndices():Void {
		set('indices', indices.join(','));
	}

	/* determine the key for the given index */
	private function indexKey(name : String):String {
		return 'indices[$name]';
	}
	private inline function ik(n : String):String return indexKey( n );

	/* determine the key for the given row */
	private function rowKey(key : String):String {
		return 'rows[$key]';
	}
	private inline function rk(n : String):String return rowKey( n );

	/* determine the key for the given row */
	private function rowIndexKey(row:String, index:String):String {
		return 'rows[$row].$index';
	}
	private inline function rik(n:String, i:String):String return rowIndexKey(n, i);

/* === Instance Fields === */

	public var key : String;
	public var autoIncrement : Bool;
	public var indices : Array<String>;

/* === Static Methods === */

	/**
	  * Create a new Table on the given Storage
	  */
	public static function create(store:Storage, spec:TableSpec, cb:Table->Void):Void {
		var tstore:SubStorage = new SubStorage(store.asGetter());
		tstore.autoPush = false;
		tstore.prefix = 'table:${spec.name}.';
		tstore.fetch(function() {
			tstore.set('key', spec.key);
			tstore.set('autoIncrement', spec.autoIncrement);
			tstore.set('indices', '');
			tstore.push(function() {
				var table:Table = new Table( tstore );
				table.init(cb.bind( table ));
			});
		});
	}

	/**
	  * open a Table by name on the given Storage
	  */
	public static function open(store:Storage, name:String, cb:Table->Void):Void {
		var ts = new SubStorage(store.asGetter());
		ts.prefix = 'table:$name';
		ts.fetch(function() {
			var table = new Table( ts );
			table.init(cb.bind( table ));
		});
	}
}

typedef TableSpec = {
	var name : String;
	var key : String;
	var autoIncrement : Bool;
};

typedef Index = {
	var name : String;
	@:optional var unique : Bool;
};
