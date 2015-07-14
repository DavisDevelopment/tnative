package tannus.chrome.chromedb;

import tannus.chrome.chromedb.Table;
import tannus.ds.AsyncStack;
import tannus.ds.Dict;
import tannus.ds.Object;
import tannus.ds.Promise;
import tannus.ds.promises.*;

import tannus.storage.core.IndexInfo;
import tannus.storage.core.Row;
import tannus.storage.core.TypedValue in Val;
import tannus.storage.core.Query in BaseQuery;
import tannus.storage.core.QueryComponent in Qc;
import tannus.storage.core.QueryComponent.QCBoolOp in Qbool;

using StringTools;
using Lambda;
using tannus.ds.ArrayTools;
using tannus.storage.core.TypeSystem;

@:access(tannus.chrome.chromedb.Table)
class Query extends BaseQuery {
	/* Constructor Function */
	public function new(qdat:Object, tabl:Table):Void {
		super(qdat, cast tabl);
	}

/* === Instance Methods === */

	/**
	  * Fetch the results of [this] Query
	  */
	override private function _fetch(cb : Array<Row>->Void) {
		trace('Query results being fetched..');
		var tabl:Table = cast(table, Table);
		var all:Array<Object> = tabl.data.all();
		var pkey:String = tabl.data.primary();

		for (step in comps) {
			switch (step) {
				case Qc.QCIdList( ids ):
					all = all.filter(function(x) return ids.has(x[pkey].value));

				case Qc.QCFieldValue(key, value, op):
					var test:Val->Val->Bool = Qbool.toFunction(op);
					all = all.filter(function(x) return test(x[key].fromHaxeType(), value.fromHaxeType()));

				case Qc.QCFieldValueList( checks ):
					for (check in checks) {
						var test:Val->Val->Bool = Qbool.toFunction(check.op);
						all = all.filter(function(row) {
							return test(row[check.key].fromHaxeType(), check.value.fromHaxeType());
						});
					}

				case Qc.QCFilter( test ):
					all = all.filter( test );

				case Qc.QCPluck( keys ):
					all = all.map(function(row) return row.plucka(keys));

				case Qc.QCWithout( keys ):
					all = all.map(function(row) {
						var rkeys = row.keys.without(keys);
						return row.plucka( rkeys );
					});
			}
		}

		trace('Query has been parsed..');

		var stack:AsyncStack = new AsyncStack();
		var rows:Array<Row> = new Array();

		function formatRow(o : Object) {
			stack.push(function( next ) {
				tannus.storage.core.RowData.create(table, o, function(rd) {
					rows.push(new Row(table, rd));
					next();
				});
			});
		}
		
		for (o in all)
			formatRow( o );
		stack.push(function(next) next());
		stack.run(function() {
			cb( rows );
		});
	}
}
