package tannus.chrome.chromedb;

import tannus.ds.Object;
import tannus.storage.core.IndexInfo;

using Lambda;

@:forward
abstract StackData (TStackData) {
	/* Constructor Function */
	public inline function new():Void {
		this = {
			'databases' : new Map<String, BaseData>()
		};
	}

/* === Instance Methods === */

	/**
	  * Obtain List of database-names
	  */
	public inline function list():Array<String> {
		return [for (db in bases) db.name];
	}

	/**
	  * Check for a database
	  */
	public inline function has(name : String):Bool {
		return list().has( name );
	}

	/**
	  * Remove a database
	  */
	public function drop(name : String):Bool {
		var db = get( name );
		return (bases.remove( db ));
	}

	/**
	  * Get a database
	  */
	public function get(name : String):Null<BaseData> {
		for (db in bases) {
			if (db.name == name)
				return db;
		}
		return null;
	}

	/**
	  * Serialize [this] StackData
	  */
	public inline function encode():String {
		var ser = new haxe.Serializer();
		ser.useCache = true;
		ser.useEnumIndex = true;
		ser.serialize( this );
		return ser.toString();
	}

	/**
	  * Update [this] StackData with serialized data
	  */
	public inline function decode(s : String):Void {
		var des = new haxe.Unserializer( s );
		var data:Object = des.unserialize();
		var me:Object = this;
		me.write( data );
	}

/* === Instance Fields === */

	/**
	  * Array of Bases on [this] Stack
	  */
	public var bases(get, set):Array<BaseData>;
	private inline function get_bases() {
		return this.databases;
	}
	private inline function set_bases(v : Array<BaseData>):Array<BaseData> {
		return (this.databases = v);
	}
}

typedef TStackData = {
	var databases : Map<String, BaseData>;
};

typedef BaseData = {
	var name : String;
	var tables : Map<String, TableData>;
};

typedef TableData = {
	var name : String;
	var fields : Array<IndexInfo>;
	var rows : Array<Object>;
};
