package tannus.http;

import tannus.html.Win;
import tannus.io.EventDispatcher;
import tannus.io.ByteArray;
import tannus.io.VoidSignal;
import tannus.ds.Obj;

import js.html.XMLHttpRequest;
import js.html.XMLHttpRequestResponseType in Nrt;
import js.html.ArrayBuffer;
import js.html.Blob;
import js.html.Document;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;

@:expose( 'WebRequest' )
class WebRequest extends EventDispatcher {
	/* Constructor Function */
	public function new():Void {
		super();

		req = new XMLHttpRequest();
		_listen();
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
	  * Wait for the response, as a Blob
	  */
	public inline function loadAsBlob(cb : Blob -> Void):Void {
		responseType = TBlob;
		onres( cb );
	}

	/**
	  * Wait for the response, as an ArrayBuffer
	  */
	public inline function loadAsArrayBuffer(cb : ArrayBuffer -> Void):Void {
		responseType = TArrayBuffer;
		onres( cb );
	}

	/**
	  * wait for the response, as a Document
	  */
	public inline function loadAsDocument(cb : Document -> Void):Void {
		responseType = TDoc;
		onres( cb );
	}

	/**
	  * wait for the response, as a ByteArray
	  */
	public inline function loadAsByteArray(cb : ByteArray -> Void):Void {
		loadAsArrayBuffer(function(ab) {
#if node
			cb(ByteArray.ofData((untyped __js__('Buffer'))( ab )));
#else
			cb(ByteArray.ofData( ab ));
#end
		});
	}

	/**
	  * wait for the request to finish, but don't retrieve the response data
	  */
	public inline function load(done : Void->Void):Void {
		onres(untyped done);
	}

	/**
	  * get a response header
	  */
	public inline function getResponseHeader(name : String):Null<String> return req.getResponseHeader( name );
	public inline function getAllResponseHeadersRaw():Null<String> return req.getAllResponseHeaders();
	public inline function setRequestHeader(name:String, value:String):Void req.setRequestHeader(name, value);
	public inline function abort():Void req.abort();
	public function getAllResponseHeaders():Map<String, String> {
		var m = new Map();
		var s = getAllResponseHeadersRaw();
		if (s != null) {
			var lines = s.split( '\r\n' );
			for (line in lines) {
				var p = line.separate(':');
				m[p.before] = p.after;
			}
		}
		return m;
	}

	/**
	  * wait for a response
	  */
	private function onres(cb : Dynamic -> Void):Void {
		if ( complete ) {
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

			default:
				null;
		}
	}

	/**
	  * listen to events ocurring on [req]
	  */
	private function _listen():Void {
		/* request has finished loading */
		req.addEventListener('load', function(event) {
			complete = true;
			Win.current.setTimeout(function() {
				done();
			}, 10);
		});
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
	private inline function set_responseType(v : ResponseType):ResponseType return untyped(req.responseType = cast v);

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
