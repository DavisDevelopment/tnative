package tannus.io;

import tannus.io.*;

@:forward
abstract ByteArrayBuffer (ByteArrayBufferImpl) from ByteArrayBufferImpl to ByteArrayBufferImpl {
	/* Constructor Function */
	public function new():Void {
		this = new ByteArrayBufferImpl();
	}
}
