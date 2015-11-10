package tannus.io.streams;

import haxe.io.Output;

import tannus.io.*;

class NativeOutputStream extends WritableStream<Byte> {
	/* Constructor Function */
	public function new(o : Output):Void {
		super();

		out = o;

		__init();
	}

/* === Instance Methods === */

	/**
	  * Initialize [this] Stream
	  */
	private inline function __init():Void {
		writeEvent.on( forward );
	}

	/**
	  * Forward written Bytes to [out]
	  */
	private function forward(c : Byte):Void {
		out.writeByte( c );
	}

	/**
	  * Flush [this] Stream
	  */
	override public function flush(?done : Void->Void):Void {
		super.flush();
		out.flush();
		if (done != null) {
			done();
		}
	}

	/**
	  * Open [this] Stream
	  */
	override public function open(?f : Void->Void):Void {
		super.open();
		if (f != null)
			f();
	}

	/**
	  * Close [this] Stream
	  */
	override public function close(?f : Void->Void):Void {
		super.close();
		out.close();
		if (f != null)
			f();
	}

/* === Instance Fields === */

	private var out : Output;
}
