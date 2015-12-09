package tannus.io.streams;

import tannus.io.*;
import tannus.node.WritableStream in Writable;

class NodeOutputStream extends WritableStream<Byte> {
	/* Constructor Function */
	public function new(o : Writable):Void {
		super();

		out = o;
		q = new ByteArray();

		__init();
	}

/* === Instance Methods === */

	/**
	  * Initialize [this] Stream
	  */
	private inline function __init():Void {
		writeEvent.on( queueByte );
	}

	/**
	  * Queue a Byte to be written
	  */
	private function queueByte(c : Byte):Void {
		q.push( c );
	}

	/**
	  * Open [this] Stream
	  */
	override public function open(?f:Void->Void):Void {
		super.open();
		if (f != null) {
			f();
		}
	}

	/**
	  * Close [this] Stream
	  */
	override public function close(?f:Void->Void):Void {
		super.close();
		flush(function() {
			out.end(function() {
				if (f != null)
					f();
			});
		});
	}

	/**
	  * Flush [this] Stream
	  */
	override public function flush(?f:Void->Void):Void {
		super.flush();
		out.write(q, function() {
			if (f != null) {
				f();
			}
		});
	}

/* === Instance Fields === */

	private var out : Writable;
	private var q : ByteArray;
}
