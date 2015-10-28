package tannus.chrome;

import tannus.chrome.Windows;
import tannus.chrome.WindowType;
import tannus.chrome.WindowState;
import tannus.chrome.WindowData;
import tannus.chrome.Tabs;
import tannus.chrome.Tab;

import tannus.ds.EitherType;
import tannus.ds.Object;
import tannus.ds.Promise;
import tannus.ds.promises.*;

@:forward
abstract Window (TWindow) from TWindow {
	/* Constructor Function */
	public function new(tw : TWindow):Void {
		this = tw;
	}

/* === Instance Methods === */

	/**
	  * Update [this] Window
	  */
	public inline function update(changes:Object, done:Void->Void) {
		Windows.update(this.id, changes).then(function( win ) {
			this = cast win;
			done();
		});
	}

	/**
	  * Alter the 'state' of [this] Window
	  */
	public inline function state(nstate:WindowState, cb:Void->Void) {
		update({'state' : nstate}, cb);
	}

	/**
	  * Shift focus to [this] Window
	  */
	public inline function focus(nfoc:Bool=true, cb:Void->Void):Void {
		update({'focused' : nfoc}, cb);
	}

	/**
	  * Minimize [this] Window
	  */
	public function minimize(cb : Void->Void) state(Minimized, cb);

	/**
	  * Maximize [this] Window
	  */
	public function maximize(cb : Void->Void) state(Maximized, cb);

	/**
	  * Return [this] Window to Normal
	  */
	public function normalize(cb : Void->Void) state(Normal, cb);

	/**
	  * Place [this] Window in FullScreen Mode
	  */
	public function fullscreen(cb : Void->Void) state(FullScreen, cb);

	/**
	  * Close [this] Window
	  */
	public inline function close(cb : Void->Void) {
		Windows.remove(this.id, cb);
	}
}

/**
  * Super Basic (Incomplete) Model of the Window Objects returned by chrome.windows.getAll()
  */
private typedef TWindow = {
	id : Null<Int>,
	focused : Bool,
	top : Null<Int>,
	left : Null<Int>,
	width : Null<Int>,
	height : Null<Int>,
	incognito : Bool,
	type : WindowType,
	state : WindowState,
	tabs : Array<Tab>,
	alwaysOnTop : Bool,
	sessionId : Null<String>
};
