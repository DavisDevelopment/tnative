package tannus.io;


#if python
	typedef BinaryData = python.Bytearray;
#elseif js
	typedef BinaryData = js.html.ArrayBuffer;
#else
	typedef BinaryData = Array<Int>;
#end
