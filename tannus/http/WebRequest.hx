package tannus.http;

import tannus.io.EventDispatcher;
import tannus.io.VoidSignal;
import tannus.ds.Obj;

import js.html.XMLHttpRequest;
import js.html.ArrayBuffer;
import js.html.Blob;

class WebRequest {
	/* Constructor Function */
	public function new():Void {
		super();

		req = new XMLHttpRequest();
	}

/* === Instance Methods === */

	/**
	  * Open [this] Request
	  */
	public inline function open(method:String, url:String):Void {
		req.open(method, url);
	}

	/**
	  * Send [this] Request
	  */
	public inline function send(?data : Dynamic):Void {
		req.send(untyped data);
	}

	/**
	  * Wait for the response, as a String
	  */
	public inline function loadAsText(cb : String -> Void):Void {
		responseType = TText;
		onres( cb );
	}

	/**
	  * Wait for the response, as a JSON object
	  */
	public function loadAsObject(cb : Obj -> Void):Void {
		responseType = TJson;
		onres(function(o : Dynamic) {
			cb(Obj.fromDynamic( o ));
		});
	}

	/**
	  * Wait for the response, as an ArrayBuffer
	  */
	public inline function loadAsArrayBuffer(cb : ArrayBuffer -> Void):Void {
		responseType = TArrayBuffer;
		onres( cb );
	}

	/**
	  * wait for a response
	  */
	private function onres(cb : Dynamic -> Void):Void {
		if ( !complete ) {
			cb( req.response );
		}
		else {
			addSignal(eventName());
			once(eventName(), cb);
		}
	}

	/**
	  * listen to events on [req]
	  */
	private inline function listen():Void {
		req.onreadystatechange = readyStateChanged.bind();
	}

	/**
	  * called when the readyState of [req] changes
	  */
	private function readyStateChanged():Void {
		switch ( readyState ) {
			case HeadersReceived:
				trace(req.getAllResponseHeaders());

			case Done:
				done();
				complete = true;
		}
	}

	/**
	  * when [this] Request has completed
	  */
	private function done():Void {
		dispatch(eventName(), req.response);
	}

	/**
	  * Get the name of the event fired for each response-type
	  */
	private function eventName():String {
		return 'got-$responseType';
	}

/* === Computed Instance Fields === */

	/* the ready state of [this] shit */
	public var readyState(get, never) : ReadyState;
	private inline function get_readyState():ReadyState return req.readyState;

	/* the response type of [this] shit */
	public var responseType(get, set):ResponseType;
	private inline function get_responseType():ResponseType return cast(req.responseType, String);
	private inline function set_responseType(v : ResponseType):ResponseType return (req.responseType = v);

/* === Instance Fields === */

	private var req : XMLHttpRequest;
	private var complete : Bool = false;
}

@:enum
abstract ResponseType (String) from String to String {
	var TText = 'text';
	var TJson = 'json';
	var TArrayBuffer = 'arraybuffer';
	var TBlob = 'blob';
	var TDoc = 'document';

	@:from
	public static inline function fromString(v : String):ResponseType {
		return switch ( v ) {
			case '', 'text': TText;
			case 'json': TJson;
			case 'arraybuffer': TArrayBuffer;
			case 'blob': TBlob;
			case 'document': TDoc;
			default: TText;
		}
	}
}

@:enum
abstract ReadyState (Int) from Int to Int {
	var Unsent = 0;
	var Opened = 1;
	var HeadersReceived = 2;
	var Loading = 3;
	var Done = 4;
}
