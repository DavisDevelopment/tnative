package tannus.storage.core;

import tannus.storage.core.*;

import tannus.ds.AsyncStack;
import tannus.ds.Dict;
import tannus.ds.EitherType;
import tannus.ds.Maybe;
import tannus.ds.Object;
import tannus.ds.Promise;
import tannus.ds.promises.*;

/**
  * Object representing a 'row' of data retrieved from a Table
  */
class Row {
	/* Constructor Function */
	public function new(parent:Table, dat:RowData):Void {
		table = parent;
		data = dat;
	}

/* === Instance Methods === */

	/**
	  * Obtain an Object copy of [this] Row's data
	  */
	public function getData():Object {
		return (data.toObject());
	}

	/**
	  * Get the a field of [this] Row
	  */
	public function get(key : String):Dynamic {
		return data.get( key );
	}

	/**
	  * Update [this] Row
	  */
	public function update(changes : Object):BoolPromise {
		var upd = table.update(id, changes);
		upd.yep(function() {
			table.row(id).then(function(urow) {
				data = urow.data;
			});
		});
		return upd;
	}

	/**
	  * Check for a field
	  */
	public function exists(key : String):Bool {
		return data.exists( key );
	}

	/**
	  * Delete [this] Row
	  */
	public function delete():BoolPromise {
		var del = table.delete(id);
		del.yep(function() {
			null;
		});
		return del;
	}

/* === Computed Instance Fields === */

	/* The 'id' of [this] Row */
	public var id : String;
	private function get_id():String {
		for (x in data.info) {
			var field = x.value;
			if (field.primary)
				return (get(field.name) + '');
		}
		throw 'TypeError: Could not locate row id!';
	}

/* === Instance Fields === */

	/* The Table [this] Row is in */
	public var table : Table;

	/* The underlying data for [this] Row */
	public var data : RowData;
}
