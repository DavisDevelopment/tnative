package tannus.ds;

import tannus.ds.Promise;
import tannus.ds.AsyncStack;
import haxe.ds.Vector;
import tannus.ds.promises.ArrayPromise;
import tannus.io.Ptr;

import haxe.macro.Context;
import haxe.macro.Expr;

using Lambda;
using haxe.macro.ExprTools;
@:forward(length)
abstract Promises<T> (Array<Promise<T>>) from Array<Promise<T>> {
	/* Constructor Function */
	public inline function new(?list : Array<Promise<T>>):Void {
		this = (list != null ? list : new Array());
	}

/* === Instance Methods === */
	
	/**
	  * Create an ArrayPromise to be fulfilled when all Promises have been fulfilled
	  */
	public function makeAll():ArrayPromise<T> {
		var i:Int = 0;
		var vres:Vector<T> = new Vector(this.length);
		var res:Ptr<Vector<T>> = Ptr.create( vres );
		var stack:AsyncStack = new AsyncStack();

		for (promise in this.iterator()) {
			makePromise(promise, i, res);
			stack.push(function( next ) {
				promise.always( next );
				promise.make();
			});
		}

		return Promise.create({
			stack.run(function() {
				return vres.toArray();
			});
		}).array();
	}

	/**
	  * Handle the fulfilling of a single Promise, in relation to the others in the set
	  */
	private function makePromise(prom:Promise<T>, index:Int, results:Ptr<Vector<T>>):Void {
		var result = Ptr.create( (results._)[index] );

	}
}
