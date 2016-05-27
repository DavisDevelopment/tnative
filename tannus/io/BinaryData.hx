package tannus.io;


#if (js && !node)
	typedef BinaryData = js.html.ArrayBuffer;
#elseif (js && node)
	typedef BinaryData = tannus.node.Buffer;
#else
	typedef BinaryData = haxe.io.Bytes;
#end
