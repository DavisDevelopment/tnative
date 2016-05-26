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

class Row {
	/* Constructor Function */
	public function new(t:Table, data:Obj):Void {
		table = t;
		r = data;
	}

/* === Instance Methods === */

	/* get list of all keys */
	public inline function keys():Array<String> return r.keys();

	/* get the value of a property of [this] Row */
	public inline function get<T>(k : String):T return r.get( k );

	/* set the value of a property of [this] Row */
	public inline function set<T>(k:String, v:T):T return r.set(k, v);

	/* update [this] Row */
	public inline function update(?cb : Void->Void):Void {
		table.updateRow(id, r, cb);
	}

	/* delete [this] Row */
	public inline function delete(?cb : Void->Void):Void {
		table.deleteRow(id, cb);
	}

/* === Computed Instance Fields === */

	/* the 'id' of [this] Row */
	public var id(get, never):String;
	private inline function get_id():String {
		return get( table.key );
	}

/* === Instance Fields === */

	private var table : Table;
	private var r : Obj;
}
