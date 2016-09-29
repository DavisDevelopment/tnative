package tannus.ds;

import tannus.io.Input;
import tannus.io.Signal;
import tannus.io.Input.Err;
import tannus.io.Signal;
import tannus.io.VoidSignal;

import tannus.ds.impl.AsyncIterationDataSource in Aids;
import tannus.ds.impl.AsyncIterationContext in Ctx;
import tannus.ds.impl.AsyncIterToken;
import tannus.ds.impl.FunctionalAsyncDataSource.SourceFunction in FDSourceFunction;
import tannus.ds.impl.FunctionalAsyncIterationContext.FAICSpec;
import tannus.ds.impl.AsyncIteratorTools in Ait;
import tannus.ds.impl.*;

import haxe.macro.Context;
import haxe.macro.Expr;

using Lambda;
using tannus.ds.ArrayTools;
using StringTools;
using tannus.ds.StringUtils;
using tannus.macro.MacroTools;
using haxe.macro.ExprTools;

/**
  * main asynchronous-iteration model
  */
class AsyncIterator<T> {
	/* Constructor Function */
	public function new(src : Aids<T>):Void {
		source = src;

		iterationRunning = false;
		loopRunning = false;
		loopStopped = false;

		onexception = new Signal();
		onend = new VoidSignal();
	}

/* === Instance Methods === */

	//public function unless(errorHandler : Err->Void):AsyncIterator<T> {
		//onexception.once( errorHandler );
		//return this;
	//}

	public function then(f : Void->Void):AsyncIterator<T> {
		onend.once( f );
		return this;
	}

	/**
	  * 'iterate' over [this]
	  */
	public function iterate(body:Ctx<T>, ?callback:Void->Void):AsyncIterator<T> {
		//source = new Aids();
		context = body;
		context.__stop = (function() {
			loopStopped = true;
			onend.fire();
			if (callback != null) {
				callback();
			}
		});

		loop(function() {
			null;
		});

		return this;
	}

	/**
	  * method for handling the recursive asynchronous-iteration algorithm
	  */
	private function loop(callback:Void->Void):Void {
		next(function( token ) {
			switch ( token ) {
				case TNext( value ):
					context.run(value, function() {
						if ( !loopStopped ) {
							loop( callback );
						}
					});

				case TEnd:
					context.end();

				default:
					null;
			}
		});
	}

	/**
	  * method used to obtain the result of an iteration as a Token
	  */
	private function next(callback : AsyncIterToken<T> -> Void):Void {
		if ( iterationRunning ) {
			throw 'Error: Each iteration must complete before the next one may begin';
		}

		iterationRunning = true;
		source._reset();

		source.provide = (function(token : AsyncIterToken<T>) {
			iterationRunning = false;
			callback( token );
		});

		//__iteration( source );
		source.run();
	}

	/**
	  * method overridden by subclasses
	  */
	//private function __iteration(src : Aids<T>):Void {
		//d.end();
	//}

	private function __raise(error : Dynamic):Void {
		loopStopped = true;
		onexception.call( error );
	}

	private function __done():Void {
		loopStopped = true;
		onend.fire();
	}

/* === Instance Fields === */

	private var context : Ctx<T>;
	private var source : Aids<T>;

	private var iterationRunning:Bool;
	private var loopRunning : Bool;
	private var loopStopped : Bool;

	private var onexception : Signal<Err>;
	private var onend : VoidSignal;

/* === Static Methods === */

	/**
	  * construct an asynchronous iterator functionally
	  */
	public static inline function createSource<T>(body : FDSourceFunction<T>):AsyncIterationDataSource<T> {
		return new FunctionalAsyncDataSource( body );
	}

	/**
	  * construct an asynchronous cursor
	  */
	public static inline function createCursor<T>(use_data:T->(Void->Void)->Void, ?after_data:Void->Void):FunctionalAsyncIterationContext<T> {
		//var o:FAICSpec<T> = untyped {};
		return new FunctionalAsyncIterationContext({
			body: use_data,
		        footer: after_data
		});
	}

	/**
	  * allow for less verbose expression of AsyncIterationDataSources, using generator-like syntax
	  */
	public static macro function macSource<T>(body : Expr):ExprOf<AsyncIterationDataSource<T>> {
		var generator:Expr = Ait.buildGeneratorFunction( body );
		return (macro tannus.ds.AsyncIterator.createSource( $generator ));
	}
}
