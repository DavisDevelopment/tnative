package tannus.html;

import js.Browser.window in win;
import js.html.Window in CWin;

import tannus.ds.Object;
import tannus.ds.Maybe;
import tannus.ds.Range;
import tannus.io.Ptr;
import tannus.io.Signal;
import tannus.events.KeyboardEvent;
import tannus.events.EventMod;

import tannus.geom.Point;
import tannus.geom.Rectangle;
import tannus.geom.Angle;
import tannus.geom.Area;
import tannus.geom.Velocity;

using StringTools;
using Lambda;

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
	public function onScroll():Signal<Point> {
		var sig:Signal<Point> = new Signal();
		var handlr = function(event) {
			var scroll:Point = new Point(this.scrollX, this.scrollY);

			sig.call( scroll );
		};
		this.addEventListener('scroll', handlr);
		sig.ondelete = (function() this.removeEventListener('scroll', handlr));
		return sig;
	}

	/**
	  * Listen for 'resize' events on [this] Window
	  */
	public function onResize():Signal<Area> {
		var sig:Signal<Area> = new Signal();
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

/* === Instance Fields === */

	/**
	  * The current viewport
	  */
	public var viewport(get, never):Rectangle;
	private inline function get_viewport():Rectangle {
		return new Rectangle(this.scrollX, this.scrollY, this.innerWidth, this.innerHeight);
	}

/* === Static Fields === */

	/**
	  * The current Window
	  */
	public static var current(get, never):Win;
	private static inline function get_current() return new Win();
}
