package tannus.storage.core;

import tannus.ds.Object;
import tannus.ds.Dict;
import tannus.ds.Maybe;

import tannus.storage.core.IndexInfo;
import tannus.storage.core.IndexType;
import tannus.storage.core.TypedValue in Val;

using tannus.storage.core.TypeSystem;

/**
  * Type to represent the underlying data for a Row
  */
abstract RowData (TRowData) from TRowData {
	/* Constructor Function */
	public inline function new(rd : TRowData):Void {
		this = rd;
	}

/* === Instance Methods === */

	/**
	  * Obtain a field-value
	  */
	@:arrayAccess
	public function get(key : String):Null<Dynamic> {
		if (exists( key )) {
			return (values[key].toHaxeType());
		}
		else
			return null;
	}

	/**
	  * Assign a new field-value
	  */
	@:arrayAccess
	public function set(key:String, value:Dynamic):Dynamic {
		values[key] = value.fromHaxeType();
		return get( key );
	}

	/**
	  * Check for existence of [key]
	  */
	public inline function exists(key : String):Bool {
		return (values.exists( key ));
	}

	/**
	  * Delete a field
	  */
	public function remove(key : String):Bool {
		var had:Bool = exists( key );
		values.remove( key );
		return had;
	}

	/**
	  * Iterate over [this]
	  */
	public inline function iterator() {
		return (values.iterator());
	}

	/**
	  * Convert to an Object
	  */
	@:to
	public function toObject():Object {
		var o:Object = {};
		for (k in keys)
			o[k] = get(k);
		return o;
	}

/* === Instance Fields === */

	/**
	  * Array of keys
	  */
	public var keys(get, never):Array<String>;
	private inline function get_keys() {
		return [for (r in values.iterator()) r.key];
	}

	/**
	  * Field Values
	  */
	public var values(get, never):Dict<String, Val>;
	private inline function get_values() {
		return (this.values);
	}

	/**
	  * Field Info
	  */
	public var info(get, never):Dict<String, IndexInfo>;
	private inline function get_info() {
		return (this.info);
	}

/* === Static Methods === */

	/**
	  * Obtain a RowData instance
	  */
	public static function create(table:Table, row:Object, cb:RowData->Void) {
		table.indexList().then(function( infos ) {
			var vals:Dict<String, Val> = new Dict();
			for (k in row.keys)
				vals[k] = row[k].value.fromHaxeType();
			var rd = new RowData({'values':vals, 'info': infos});
			cb( rd );
		});
	}
}

/**
  * Underlying type definition for RowData
  */
typedef TRowData = {
	/* Fields for [this] Row */
	var values : Dict<String, Val>;

	/* MetaData on [this] Row's Fields */
	var info : Dict<String, IndexInfo>;
};
