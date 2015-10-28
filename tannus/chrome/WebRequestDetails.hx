package tannus.chrome;

import tannus.ds.Object;

using Lambda;
using tannus.ds.ArrayTools;

@:forward
abstract WebRequestDetails (BaseDetails) from BaseDetails to BaseDetails {
	
}

typedef BaseDetails = {
	var requestId : String;
	var frameId : Int;
	var parentFrameId : Int;
	var tabId : Int;
	var timeStamp : Float;
	var type : ResourceType;
	var url : String;
	var method : String;

	@:optional var statusCode : Int;
	@:optional var statusLine : String;
	@:optional var requestBody : {?error:String, ?formData:Object, ?raw:Array<Dynamic>};
	@:optional var requestHeaders : HttpHeaders;
	@:optional var responseHeaders : HttpHeaders;
};

typedef DetailsCallback = BaseDetails -> Null<Dynamic>;

@:enum
abstract ResourceType (String) from String to String {
	var MainFrame = 'main_frame';
	var SubFrame = 'sub_frame';
	var Stylesheet = 'stylesheet';
	var Script = 'script';
	var Image = 'image';
	var Object = 'object';
	var Xhr = 'xmlhttprequest';
	var Other = 'other';
}

// typedef HttpHeaders = Array<HttpHeader>;
abstract HttpHeaders (Array<HttpHeader>) from Array<HttpHeader> to Array<HttpHeader> {
	public inline function new(list : Array<HttpHeader>):Void {
		this = list;
	}

	public function get_header(name:String):Null<HttpHeader> {
		return (this.firstMatch(h, (h.name == name)));
	}

	@:arrayAccess
	public function get(name : String):Null<String> {
		var h:Null<HttpHeader> = get_header(name);
		if (h == null)
			return null
		else {
			return h.value;
		}
	}

	@:arrayAccess
	public function set(name:String, val:String):String {
		var h:Null<HttpHeader> = get_header(name);
		if (h == null) {
			h = {
				'name': name,
				'value': val
			};
			this.push(h);
			return val;
		}
		else {
			return (h.value = val);
		}
	}

	@:to
	public function toHash():Object {
		var o:Object = {};
		for (h in this)
			o[h.name] = h.value;
		return o;
	}
}

typedef HttpHeader = {
	var name : String;
	@:optional var value : String;
	@:optional var binaryValue : Dynamic;
};

@:forward
abstract RequestFilter (TRequestFilter) from TRequestFilter {
	/* Constructor Function */
	public inline function new(hrefs:Array<String>, ?types:Array<ResourceType>, ?tabid:Int, ?winid:Int):Void {
		this = {'urls': hrefs, 'types':types, 'tabId': tabid, 'windowId': winid};
	}

	/* from String */
	@:from
	public static inline function fromString(s : String):RequestFilter {
		return new RequestFilter([s]);
	}
}

typedef TRequestFilter = {
	var urls : Array<String>;
	@:optional var types : Array<ResourceType>;
	@:optional var tabId : Int;
	@:optional var windowId : Int;
};
