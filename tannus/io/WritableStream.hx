package tannus.io;

import tannus.io.ByteArray;
import tannus.io.Signal;

import tannus.internal.Error;

@:allow(tannus.io.StreamAccessor)
class WritableStream<T> {
	/* Constructor Function */
	public function new():Void {
		writeEvent = new Signal();
		_buf = new Array();

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
	public function write(data : T):Void {
		if (writable) {
			if (paused) {
				_buf.push(data);
			}
			else {
				writeEvent.call( data );
			}
		}
		else {
			error('Cannot write to closed or unopened Stream!');
		}
	}

	/**
	  * Flush the Buffer
	  */
	public function flush(?done : Void->Void):Void {
		for (d in _buf) {
			writeEvent.call( d );
		}
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

	private var writeEvent : Signal<T>;
	private var _buf : Array<T>;

	private var opened : Bool;
	private var closed : Bool;
	private var paused : Bool;
}
