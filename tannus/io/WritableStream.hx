package tannus.io;

import tannus.io.ByteArray;
import tannus.io.Signal;

import tannus.internal.Error;

@:allow(tannus.io.StreamAccessor)
class WritableStream<T> {
	/* Constructor Function */
	public function new():Void {
		//writeEvent = new Signal();
		__b = new Array();

		opened = closed = paused = false;
	}

/* === Instance Methods === */

	/**
	  * Open [this] Stream
	  */
	public function open(?f : Void->Void):Void {
		opened = true;
	}

	/**
	  * Close [this] Stream
	  */
	public function close(?f : Void->Void):Void {
		closed = true;
	}

	/**
	  * Pause [this] Stream
	  */
	public function pause():Void {
		paused = true;
	}

	/**
	  * Resume [this] Stream
	  */
	public function resume():Void {
		if (paused) {
			paused = false;
			flush();
		}
	}

	/**
	  * Write some data onto [this] Stream
	  */
	public function write(data:T, ?onwritten:Void->Void):Void {
		if ( writable ) {
			if ( paused ) {
				__b.push( data );
			}
			else {
				if (onwritten == null) {
					onwritten = (function() null);
				}

				__write(data, onwritten);
			}
		}
		else {
			error('Cannot write to closed or unopened Stream!');
		}
	}

	/**
	  * method used internally to write data
	  */
	private function __write(data:T, onwritten:Void->Void):Void {
		throw 'Not implemented';
	}

	/**
	  * Flush the Buffer
	  */
	public function flush(?done : Void->Void):Void {
		var stack = new tannus.ds.AsyncStack();
		while (__b.length > 0) {
			stack.push(__write.bind(__b.shift(), _));
		}
		stack.run(function() {
			if (done != null) {
				done();
			}
		});
	}

	/**
	  * Add the given data to the Buffer
	  */
	private inline function buffer(data : T):Void {
		__b.push( data );
	}

	/**
	  * Throw an Error
	  */
	private inline function error(e : Error):Void {
		throw e;
	}

/* === Computed Instance Fields === */

	/* whether [this] stream can be written */
	public var writable(get, never) : Bool;
	private inline function get_writable():Bool {
		return (opened && !closed);
	}

/* === Instance Fields === */

	private var __b : Array<T>;

	private var opened : Bool;
	private var closed : Bool;
	private var paused : Bool;
}
