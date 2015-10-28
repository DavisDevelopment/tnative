package tannus.http;

import haxe.Http in Req;

import tannus.ds.Object;
import tannus.ds.Promise;
import tannus.ds.promises.*;
import tannus.io.ByteArray;
import tannus.io.Signal;

class Request {
	/* Constructor Function */
	public function new(addr : String):Void {
		url = addr;
		req_headers = new Map();
		res_headers = new Map();
		params = new Map();

		statusChange = new Signal();
		error = new Signal();
		data = new Signal();
	}

/* === Instance Methods === */

	/**
	  * Manipulate the request headers
	  */
	public function header(key:String, ?val:String):String {
		if (val == null) {
			return (req_headers[key]);
		}
		else {
			return (req_headers[key] = val);
		}
	}

	/**
	  * Manipulate the GET parameters
	  */
	public function param(key:String, ?val:String):String {
		if (val != null)
			return (params[key] = val);
		else
			return (params[key]);
	}

	/**
	  * Create a Promise from [this] Request
	  */
	public function promise(sendNow:Bool=false, post:Bool=false):StringPromise {
		return Promise.create({
			error.on(function( err ) {
				throw err;
			});

			data.on(function( dat ) {
				return dat;
			});
			if (sendNow)
				send( post );
		}).string();
	}

	/**
	  * Actually Send the Request
	  */
	public function send(?post:Bool=false):Void {
		var req:Req = new Req( url );
		
		/* Copy Headers onto [req] */
		for (k in req_headers.keys())
			req.addHeader(k, req_headers[k]);
		
		/* Copy Parameters onto [req] */
		for (k in params.keys())
			req.addParameter(k, params[k]);

		/* Register Event Handlers */
		req.onError = error.call.bind( _ );
		req.onStatus = statusChange.call.bind(_);
		req.onData = data.call.bind(_);

		req.request( post );
	}

/* === Instance Fields === */

	public var url : String;
	private var req_headers : Map<String, String>;
	private var res_headers : Map<String, String>;
	private var params : Map<String, String>;

	public var statusChange : Signal<Int>;
	public var error : Signal<String>;
	public var data : Signal<String>;

/* === Static Method === */

	/**
	  * Shorthand method to create a new Request, and return a Promise of it's data
	  */
	public static function request(url:String, post:Bool=false, ?params:Map<String, String>, ?headers:Map<String, String>):StringPromise {
		var r = new Request( url );
		if (params != null)
			r.params = params;
		if (headers != null)
			r.req_headers = headers;
		return r.promise(true, post);
	}
}
