package tannus.ds;

import tannus.ds.data.*;

import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.macro.ExprTools;
using tannus.macro.MacroTools;
using Lambda;
using tannus.ds.ArrayTools;

@:forward
abstract DataView<T> (IData<T>) from IData<T> to IData<T> {
	/* Constructor Function */
	public inline function new(size:Int, ?value:T):Void {
		this = new Data(size, value);
	}

/* === Instance Methods === */

	@:arrayAccess
	public inline function get(index:Int):Null<T> return this.get(index);
	@:arrayAccess
	public inline function set(i:Int, v:Null<T>):Null<T> return this.set(i, v);

	public macro function with(self:ExprOf<DataView<T>>, rest:Array<Expr>) {
		var action:Expr = rest.pop();
		var values = rest.copy();
		for (i in 0...values.length) {
			action = action.replace(values[i], macro $self[$v{i}]);
		}
		return action;
	}

	@:from
	public static inline function fromVector<T>(vector : haxe.ds.Vector<T>):DataView<T> {
		return Data.fromDataImpl( vector );
	}
	@:from
	public static inline function fromArray<T>(array : Array<T>):DataView<T> {
		return Data.fromArray( array );
	}

	/**
	  * macro method to create a BoundData view
	  */
	public static macro function createBoundView<T>(values : Array<ExprOf<T>>):ExprOf<DataView<T>> {
		values = values.map(function( ve ) {
			return macro tannus.io.Ptr.create( $ve );
		});
		var valuesDef:ExprOf<Array<tannus.io.Ptr<T>>> = cast {
			expr: EArrayDecl( values ),
			pos : Context.currentPos()
		};
		return macro new tannus.ds.data.BoundData( $valuesDef );
	}
}
