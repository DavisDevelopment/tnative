package tannus.http;

import tannus.io.ByteArray;
import tannus.http.*;
import tannus.http.BaseRequest in Base;

@:forward
abstract Request (Base) from Base to Base {
	/* Constructor Function */
	public inline function new(url:Url, ?method:String):Void {
		this = (cast new ReqImpl(url, method));
	}
}

#if node
	typedef ReqImpl = tannus.http.NodeRequest;
#else
	typedef ReqImpl = tannus.http.BaseRequest;
#end