package tannus.io;


#if python
	typedef BinaryData = python.Bytearray;
#elseif (js && !node)
	typedef BinaryData = js.html.ArrayBuffer;
#elseif (js && node)
	typedef BinaryData = tannus.node.Buffer;
#else
	typedef BinaryData = Array<Int>;
#end
