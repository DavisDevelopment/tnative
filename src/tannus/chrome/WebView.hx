package tannus.chrome;

import tannus.html.Element;
import tannus.ds.AsyncStack;
import tannus.ds.Object;
import tannus.html.WindowMessager in Socket;
import tannus.io.Signal;

class WebView {
	/* Constructor Function */
	public function new(?url : String):Void {
		el = '<webview></webview>';
		view = cast el.toHTMLElement();
		if (url != null)
			src = url;

		contentLoaded = new Signal();

		el.on('loadstop', function(e) {
			contentLoaded.call( this );
		});
	}

/* === Instance Methods === */

	/**
	  * Execute a Script in the context of [this] WebView
	  */
	public function executeScript(path:String, cb:Void->Void):Void {
		view.executeScript({'file': path}, cb);
	}

	/**
	  * Execute multiple Scripts in sequence
	  */
	public function executeScripts(paths:Array<String>, cb:Void->Void):Void {
		var stack = new AsyncStack();
		for (p in paths)
			stack.push(executeScript.bind(p, _));
		stack.run( cb );
	}

	/**
	  * Connect to [this] WebView with a Socket
	  */
	public function connectSocket(cb:Socket->Void):Void {
		var sock = new Socket(true);
		sock.connectWindow(view.contentWindow, function() {
			cb( sock );
		});
	}

/* === Computed Instance Fields === */

	/**
	  * The url of [this] WebView
	  */
	public var src(get, set):String;
	private inline function get_src() return view.src;
	private inline function set_src(ns : String) return (view.src = ns);

	/**
	  * The width of [this] WebView
	  */
	public var width(get, set):Float;
	private inline function get_width() return el.w;
	private inline function set_width(nw : Float) return (el.w = nw);

	/**
	  * The height of [this] WebView
	  */
	public var height(get, set):Float;
	private inline function get_height() return el.h;
	private inline function set_height(nh) return (el.h = nh);

/* === Instance Fields === */

	public var el : Element;
	public var view : WView;
	public var contentLoaded : Signal<WebView>;
}

@:native('WebView')
extern class WView extends js.html.Element {
	/* The url of [this] Webview */
	var src : String;
	
	/* The Window object of [this] WebView */
	var contentWindow : js.html.Window;

	/* Execute a Script in the context of [this] Webview */
	function executeScript(details:InjectDetails, cb:Void->Void):Void;
}

typedef InjectDetails = {
	?code : String,
	?file : String
};
