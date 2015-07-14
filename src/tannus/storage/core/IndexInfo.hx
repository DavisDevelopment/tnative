package tannus.storage.core;

import tannus.storage.core.IndexType;
import tannus.storage.core.TypeSystem in Ts;

@:forward
abstract IndexInfo (TIndexInfo) from TIndexInfo {
	/* Constructor Function */
	public inline function new(n:String, t:String, p:Bool=false, r:Bool=true, u:Bool=false):Void {
		this = {
			'name' : n,
			'type' : Ts.typeFromName(t),
			'required' : r,
			'primary' : p,
			'unique' : u
		};
	}
}

/**
  * Type Definition for the data given upon creating a new Index on a Table
  */
typedef TIndexInfo = {
	/**
	  * The 'name' of [this] Index
	  */
	var name : String;

	/**
	  * Whether [this] Index is the 'primary key', as it's known in most database systems
	  */
	var primary : Bool;

	/**
	  * Whether [this] Index is required on new Rows being inserted
	  */
	var required : Bool;

	/**
	  * Whether [this] Index must be unique
	  */
	var unique : Bool;

	/**
	  * The 'type' of [this] Index
	  */
	var type : IndexType;
};
