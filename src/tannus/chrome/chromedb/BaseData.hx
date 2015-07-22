package tannus.chrome.chromedb;

import tannus.ds.Object;
import tannus.ds.Dict;
import tannus.storage.core.IndexInfo;
import tannus.storage.core.IndexType in IType;
import tannus.storage.core.TypeSystem in Ts;
import tannus.storage.core.TypedValue;

using Lambda;

@:forward
abstract BaseData (TBaseData) {
	/* Constructor Function */
	public inline function new(name:String, tables:Map<String, TableData>):Void {
		this = {
			'name' : name,
			'tables' : tables
		};
	}

/* === Instance Methods === */

	/**
	  * Encode [this] Base
	  */
	public inline function encode():String {
		return haxe.Serializer.run( this );
	}

	/**
	  * Create a BaseData from [str] and copy it's values onto [this] one
	  */
	public inline function decode(str : String):Void {
		var des = new haxe.Unserializer( str );
		var newer:BaseData = cast des.unserialize();
		
		this.tables = newer.tables;
	}

	/**
	  * Obtain an Array of the names of all tables
	  */
	public inline function tableList():Array<String> {
		return [for (t in this.tables) t.name];
	}

	/**
	  * Obtain reference to a Table
	  */
	public inline function table(name : String):TableData {
		return this.tables[name];
	}

	/**
	  * Create a new Table
	  */
	public function createTable(name : String):TableData {
		var td:TableData = {
			'name' : name,
			'fields' : [],
			'rows' : [],
			'highest_id' : 0
		};
		if (this.tables.exists( name )) {
			throw 'TableError: Table $name already exists!';
		} 
		else {
			this.tables[name] = td;
		}
		return td;
	}

	/**
	  * Delete a Table
	  */
	public inline function deleteTable(name : String):Bool {
		return this.tables.remove( name );
	}

	/**
	  * Check for existence of a Table
	  */
	public inline function hasTable(name : String):Bool {
		return this.tables.exists( name );
	}
}

@:forward
abstract TableData (TTableData) from TTableData {
	/* Constructor Function */
	public inline function new(td : TTableData):Void {
		this = td;
	}

/* === Instance Methods === */

	/**
	  * Obtain a List of Fields
	  */
	public inline function indexNames():Array<String> {
		return [for (f in this.fields) f.name];
	}

	/**
	  * Get info on all Fields
	  */
	public function indexList():Dict<String, IndexInfo> {
		var d = new Dict();
		for (i in indexNames()) {
			d[i] = indexInfo(i);
		}
		return d;
	}

	/**
	  * Check for an index
	  */
	public inline function hasIndex(name : String):Bool {
		return indexNames().has( name );
	}

	/**
	  * Get the info on a given Index
	  */
	public function indexInfo(name : String):IndexInfo {
		for (f in this.fields)
			if (f.name == name)
				return f;
		throw 'TableError: Index $name does not exist!';
	}

	/**
	  * Create a new Index
	  */
	public inline function createIndex(info : IndexInfo):Void {
		if (hasIndex(info.name)) {
			throw 'TableError: Index ${info.name} already exists!';
		}
		else {
			this.fields.push( info );
		}
	}

	/**
	  * Remove an Index
	  */
	public inline function deleteIndex(name : String):Bool {
		if (hasIndex( name )) {
			return this.fields.remove(indexInfo( name ));
		} else return false;
	}

	/**
	  * Get the name of the primary key of [this] Table
	  */
	public function primary():String {
		var keys:Array<String> = indexNames();
		for (key in keys) {
			var info = indexInfo( key );
			if (info.primary)
				return key;
		}
		throw 'TableError: Table has no primary key!';
	}

	/**
	  * Get an Array of the names of all required fields
	  */
	public inline function required():Array<String> {
		var res:Array<String> = new Array();
		for (name in indexNames()) {
			var info = indexInfo(name);
			if (info.required)
				res.push(info.name);
		}
		return res;
	}

	/**
	  * Obtain an Array of all rows of [this] Table
	  */
	public inline function all():Array<Object> {
		return this.rows;
	}

	/**
	  * Insert a new Row onto [this] Table
	  */
	public function insert(row : Object):Void {
		/* Validations */
		var fields = indexNames();
		var nrow:Object = {};

		for (k in fields) {
			var info = indexInfo(k);
			/* if this index is the primary-key */
			if (info.primary) {
				/* if the primary-key is auto-incremented */
				if (info.autoIncrement) {
					if (row[k].exists) {
						throw 'TableError: Do not provide a "$k" field; it is auto-incremented!';
					}
					else {
						row[k] = autoIncrement();
					}
				}
			}
			if (info.required) {
				if (!row.exists(k))
					throw 'TableError: Missing field "$k"!';
			}
			var value:Dynamic = row[k];
			if (!Ts.validate(value, info.type)) {
				throw 'TableError: On Field "$k", $value should be ${info.type}!';
			}
			if (info.unique) {
				var ids:Array<Dynamic> = [for (oth in all()) oth[k]];
				if (ids.has(value))
					throw 'TableError: Field "$k" must be unique!'; 
			}
			nrow[k] = Ts.toHaxeType(Ts.fromHaxeType(value));
		}
		this.rows.push( nrow );
	}

	/**
	  * Auto-Increment the primary key, returning the newest id
	  */
	public function autoIncrement():Dynamic {
		this.highest_id += 1;
		var pkey = indexInfo(primary());
		switch (pkey.type) {
			case IType.ITInt: 
				return this.highest_id; 
			
			case IType.ITString:
				return StringTools.hex(this.highest_id);

			default:
				throw 'TableError: Cannot auto-increment a ${pkey.type} index';
		}
	}

	/**
	  * Select a Row by primary key
	  */
	public function get(id : Dynamic):Null<Object> {
		var k = primary();
		for (o in all()) {
			trace(o);
			if (o[k] == id)
				return o;
		}
		return null;
	}

	/**
	  * Delete a Row by primary key
	  */
	public function delete(id : String):Bool {
		var row = get(id);
		return this.rows.remove( row );
	}
}

typedef TBaseData = {
	var name : String;
	var tables : Map<String, TableData>;
};

typedef TTableData = {
	var name : String;
	var fields : Array<IndexInfo>;
	var rows : Array<Object>;
	var highest_id : Int;
};
