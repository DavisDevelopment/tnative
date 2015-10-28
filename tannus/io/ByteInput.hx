package tannus.io;

import tannus.io.Byte;
import tannus.io.ByteArray;
import tannus.io.Signal;


import haxe.io.Input;

class ByteInput extends Input {

	//- All Bytes read from [this] Input so far
	public var source : ByteArray;

	//- Signal to fire when all data has been read from [this] Input
	public var onComplete : Signal<ByteInput>;

	public function new(data : ByteArray):Void {
		this.source = data;
		this.onComplete = new Signal();
	}

	/**
	  * Retrieve "next" Byte from [this] Input
	  */
	public function next():Byte {
		return readByte();
	}

	/**
	  * Forces [bit] back onto the Stack of Bytes
	  */
	public function back(bit : Byte):Void {
		source.unshift( bit );
	}
	
	/**
	  * method to read next byte from [this] Input
	  */
	override public function readByte():Int {
		if (!source.empty) {
			
			var i:Int = (source.shift().toInt());
			return i;
		} else {
			onComplete.call( this );

			//throw (new haxe.io.Eof());
			throw ( 'Eof' );
		}
	}

	/**
	  * Creates a ByteInput instance from a String
	  */
	public static inline function fromString(s : String):ByteInput {
		return new ByteInput(ByteArray.fromString(s));
	}
}
