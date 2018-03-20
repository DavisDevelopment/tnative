package tannus.html;

import js.Browser.window in win;
import js.html.Window in CWin;

import tannus.io.*;
import tannus.ds.*;
import tannus.events.KeyboardEvent;
import tannus.events.EventMod;
import tannus.html.fs.WebFileSystem;
import tannus.html.JSTools;

import tannus.geom2.*;

import haxe.extern.EitherType;
import haxe.Constraints.Function;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;
using tannus.html.JSTools;

@:forward
abstract Win (CWin) from CWin to CWin {
	/* Constructor Function */
	public inline function new(?w:CWin):Void {
		this = ((w != null) ? w : win);
	}

/* === Instance Methods === */

	/**
	  * Listen for 'scroll' events on [this] Window
	  */
	public function onScroll():Signal<Point<Float>> {
		var sig:Signal<Point<Float>> = new Signal();
		var handlr = function(event) {
			var scroll:Point<Float> = cast new Point(this.scrollX, this.scrollY);

			sig.call( scroll );
		};
		this.addEventListener('scroll', handlr);
		sig.ondelete = (function() this.removeEventListener('scroll', handlr));
		return sig;
	}

	/**
	  * Listen for 'resize' events on [this] Window
	  */
	public function onResize():Signal<Area<Float>> {
		var sig:Signal<Area<Float>> = new Signal();
		var handlr = function(event) {
			var area = new Area(this.innerWidth, this.innerHeight);

			sig.call( area );
		};
		this.addEventListener('resize', handlr);
		sig.ondelete = (function() this.removeEventListener('resize', handlr));
		return sig;
	}

	/**
	  * Listen for 'keydown' events on [this] Window
	  */
	public function onKeydown():Signal<KeyboardEvent> {
		var sig:Signal<KeyboardEvent> = new Signal();
		function handle(event:js.html.KeyboardEvent) {
			var mods:Array<EventMod> = new Array();
			if (event.altKey) mods.push(Alt);
			if (event.shiftKey) mods.push(Shift);
			if (event.ctrlKey) mods.push(Control);

			var e:KeyboardEvent = new KeyboardEvent('keydown', event.keyCode, mods);

			sig.call( e );
		}

		var bod = this.document.getElementsByTagName('body').item(0);
		bod.addEventListener('keydown', handle);
		sig.ondelete = (function() bod.removeEventListener('keydown', handle));

		return sig;
	}

	/**
	  * Listen for 'beforeunload' events on [this] Window
	  */
	public function onBeforeUnload():Signal<Float> {
		var sig:Signal<Float> = new Signal();
		var handlr = function(event) {
			sig.call(Date.now().getTime());
		};
		
		this.addEventListener('beforeunload', handlr);
		sig.ondelete = (function() this.removeEventListener('beforeunload', handlr));
		return sig;
	}

	/**
	  * Request a FileSystem for use
	  */
	public function requestFileSystem(size:Int, cb:WebFileSystem->Void):Void {
		untyped {
			var self:Obj = this;
			var rfs:Dynamic = self['requestFileSystem'];
			if (rfs == null) {
				rfs = self['webkitRequestFileSystem'];
			}
			rfs(self['TEMPORARY'], size, cb);
		};
	}

	/**
	  * Expose some value globally
	  */
	public inline function expose(name:String, value:Dynamic):Void {
	    Reflect.setProperty(this, name, value);
	}

	/**
	  * Unexpose a value
	  */
	public inline function unexpose(name:String):Void {
	    Reflect.deleteField(this, name);
	}

	/**
	  * expose a Getter
	  */
	public inline function exposeGetter<T>(name:String, get:Getter<T>):Void {
		untyped (this.__defineGetter__(name, get));
	}

	/**
	  * expose a Setter
	  */
	public inline function exposeSetter<T>(name:String, set:Setter<T>):Void {
		untyped this.__defineSetter__(name, set);
	}

	/**
	  * expose a Pointer
	  */
	public inline function exposeRef<T>(name:String, ref:Ptr<T>):Void {
		exposeGetter(name, ref.getter);
		exposeSetter(name, ref.setter);
	}

	/**
	  * get a global variable
	  */
	@:arrayAccess
	public inline function get<T>(name : String):T {
		return untyped this[name];
	}

	public inline function fetch() {
	    //
	}

/* === Instance Fields === */

	/**
	  * The current viewport
	  */
	public var viewport(get, never):Rect<Float>;
	private inline function get_viewport():Rect<Float> {
		return cast new Rect(this.scrollX, this.scrollY, this.innerWidth, this.innerHeight);
	}

	public var visualViewport(get, never):Null<VisualViewport>;
	private inline function get_visualViewport():Null<VisualViewport> return get('visualViewport');

	/**
	  * [this] Window, as an object
	  */
	public var self(get, never):Obj;
	private inline function get_self():Obj return Obj.fromDynamic( this );

	public var document(get, never):js.html.HTMLDocument;
	private inline function get_document():js.html.HTMLDocument return cast this.document;

/* === Static Fields === */

	/**
	  * The current Window
	  */
	public static var current(get, never):Win;
	private static inline function get_current() return new Win();
}

@:native('VisualViewport')
extern class VisualViewport extends js.html.EventTarget {
    public var offsetLeft(default, null): Int;
    public var offsetTop(default, null): Int;
    public var pageLeft(default, null): Int;
    public var pageTop(default, null): Int;
    public var width(default, null): Int;
    public var height(default, null): Int;
    public var clientWidth(default, null): Int;
    public var clientHeight(default, null): Int;
    public var scale(default, null): Int;

    public var onresize: Null<Function>;
    public var onscroll: Null<Function>;

    private static inline function or(?a:Int, ?b:Int, c:Int):Int {
        return (untyped __js__('{0} || {1} || {2}', a, b, c));
    }

    public inline function getRect():Rect<Int> {
        return new Rect(pageLeft, pageTop, or(width, clientWidth, 0), or(height, clientHeight, 0));
    }

    public static inline function isSupported():Bool {
        return untyped __js__('(typeof {0} !== "undefined") && ({1} in {2})', VisualViewport, "visualViewport", win);
    }
}

@:native('Request')
extern class FetchRequest {
    public function new(input:EitherType<String, FetchRequest>, ?init:RequestInit):Void;
}

typedef RequestInit = { };
