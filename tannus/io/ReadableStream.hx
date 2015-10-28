package tannus.io;

import tannus.io.Signal;

class ReadableStream<T> {
	/* Constructor Functoin */
	public function new():Void {
		dataEvent = new Signal();
		errorEvent = new Signal();
		_buffer = new Array();

		opened = false;
		closed = false;
		paused = false;
	}

/* === Instance Methods === */

	/**
	  * listen for data on [this] Stream
	  */
	public function ondata(cb : T->Void):Void {
		dataEvent.on( cb );
	}

	/**
	  * listen for errors on [this] Stream
	  */
	public function onerror(cb : String->Void):Void {
		errorEvent.on( cb );
	}

	/**
	  * request a single piece of data
	  */
	public function get(cb : T->Void):Void {
		dataEvent.once(function(data : T) {
			cb( data );
			close();
		});
		open();
	}

	/**
	  * Open [this] Stream
	  */
	public function open(?cb : Void->Void):Void {
		opened = true;
	}

	/**
	  * Close [this] Stream
	  */
	public function close():Void {
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
		paused = false;
		flush();
	}

	/**
	  * Write data to the Buffer
	  */
	private function buffer(d : T):Void {
		_buffer.push( d );
	}

	/**
	  * Prepare data for reading
	  */
	private function provide(d : T):Void {
		dataEvent.call( d );
	}

	/**
	  * Either buffer or provide some data
	  */
	private inline function write(d : T):Void {
		(paused ? buffer : provide)( d );
	}

	/**
	  * Flush the Buffer
	  */
	private function flush():Void {
		for (item in _buffer) {
			dataEvent.call( item );
		}
		_buffer = new Array();
	}

/* === Instance Fields === */

	private var dataEvent : Signal<T>;
	private var errorEvent : Signal<String>;
	private var _buffer : Array<T>;
	private var opened : Bool;
	private var closed : Bool;
	private var paused : Bool;
}
