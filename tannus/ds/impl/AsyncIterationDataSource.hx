package tannus.ds.impl;

import tannus.io.Input;
import tannus.io.Signal;
import tannus.io.Input.Err;
import tannus.io.Signal;
import tannus.io.VoidSignal;

import tannus.ds.impl.AsyncIterToken;

@:allow( tannus.ds.AsyncIterator )
class AsyncIterationDataSource<T> {
	/* Constructor Function */
	public function new():Void {
		returned = false;
	}

	/**
	  * hand off the Token to the Iterator
	  */
	private dynamic function provide(token : AsyncIterToken<T>):Void {
		trace( token );
	}

	/**
	  * actually perform the operations that obtain the data to be provided
	  */
	private function run():Void {
		end();
	}

	/**
	  * reset the [returned] value
	  */
	private function _reset():Void {
		returned = false;
	}

	/**
	  * wrapper function used to hand off the Token to the Iterator, ensuring that
	  * only one Token can be handed off per iteration
	  */
	private function _post(token : AsyncIterToken<T>):Void {
		if ( returned ) {
			throw 'Error: AsyncIterators may only post one Token per iteration';
		}
		else {
			returned = true;
			//result.call( token );
			provide( token );
		}
	}

	/**
	  * provide the Iterator with the next value
	  */
	public function next(value : T) {
		_post(TNext( value ));
	}
	
	/**
	  * asynchronously 'throw' and error
	  */
	public function raise(error : Dynamic) {
		_post(TError( error ));
	}
	
	/**
	  * mark the end of the data-stream 
	  * (equivalent to 'hasNext' on a regular Iterator returning false)
	  */
	public function end() {
		_post( TEnd );
	}

/* === Instance Fields === */

	private var returned:Bool;
	//private var i:AsyncIterator<T>;
}
