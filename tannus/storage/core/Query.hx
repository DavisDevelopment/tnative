package tannus.storage.core;

import tannus.ds.Object;
import tannus.ds.AsyncStack;
import tannus.io.Signal;
import tannus.io.Ptr;
import tannus.ds.Promise;
import tannus.ds.promises.*;

import tannus.storage.core.*;
import tannus.storage.core.QueryComponent.QueryComponent in Qc;
import tannus.storage.core.QueryComponent.QCBoolOp in QBool;

/**
  * Object used to construct and fetch the results of a Table Query
  */
class Query {
	/* Constructor Function */
	public function new(qdat:Object, tabl:Table):Void {
		table = tabl;
		comps = new Array();
		onRows = new Signal();

		parseObject( qdat );
	}

/* === Query-Fetching Instance Methods === */

	/**
	  * Internal method which actually fetches the results
	  */
	private function _fetch(cb : Array<Row>->Void):Void {
		throw 'Not Implemented!';
	}

	/**
	  * Fetch the results of [this] Query
	  */
	public function fetch():RowProm {
		return Promise.create({
			try {
				_fetch(function( rows ) {
					return rows;
				});
			}
			catch (err : Dynamic) {
				throw err;
			}
		}).array();
	}

/* === Query-Manipulating Instance Methods === */

	/**
	  * Add a new field-value filter to [this] Query
	  */
	public function where(key:String, value:Dynamic, ?op:String='=='):Query {
		add(QCFieldValue(key, value, QBool.fromString(op)));
		return this;
	}

	/**
	  * Add a new filter to pass all Rows through
	  */
	public function filter(pred : Row->Bool):Query {
		add(Qc.QCFilter( pred ));
		return this;
	}

	/**
	  * Pluck a subset of indices from Rows
	  */
	public function pluck(keys : Array<String>):Query {
		add(QCPluck( keys ));
		return this;
	}

	/**
	  * Remove some indices from Rows
	  */
	public function without(keys : Array<String>):Query {
		add(QCWithout( keys ));
		return this;
	}

	/**
	  * Add a new Component to the Stack
	  */
	private function add(step : Qc):Void {
		comps.push( step );
	}

	/**
	  * Parse an Object into an Array<Qc>
	  */
	private function parseObject(o : Object):Void {
		var steps = [];

		for (key in o.keys) {
			var val:Object = new Object(o[key].value);

			steps.push({
				'key'   : key,
				'value' : val,
				'op'    : QBool.Eq
			});
		}

		add(QCFieldValueList( steps ));
	}

/* === Instance Fields === */

	/* The Table [this] Query is being applied to */
	public var table : Table;

	/* Components of [this] Query */
	public var comps : Array<QueryComponent>;

	/* Signal Fired when the Rows have be fetched */
	public var onRows : Signal<Array<Row>>;
}

private typedef RowProm = Promise<Array<Row>>;
