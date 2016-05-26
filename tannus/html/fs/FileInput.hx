package tannus.html.fs;

import js.html.InputElement;
import js.html.FileList;

import tannus.dom.Element;
import tannus.io.ByteArray;
import tannus.io.Ptr;
import tannus.io.EventDispatcher;
import tannus.io.Signal;
import tannus.ds.Promise;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;

class FileInput extends EventDispatcher {
	/* Constructor Function */
	public function new(el : Element):Void {
		super();

		input = cast el.els[0];
		inp = new Element( input );
		changed = new Signal();
		addSignal('change', changed);

		listen();
	}

/* === Instance Methods === */

	/**
	  * Listen for events on [input]
	  */
	private function listen():Void {
		input.addEventListener('change', function(event:Dynamic) {
			changed.call( input.files );
		});
	}

/* === Computed Instance Fields === */

	/* whether [this] FileInput accepts multiple files */
	public var multiple(get, set):Bool;
	private inline function get_multiple():Bool {
		return (['multiple', ''].has(inp.getAttribute('multiple')));
	}
	private inline function set_multiple(v : Bool):Bool {
		if ( v ) {
			inp.setAttribute('multiple', 'multiple');
		}
		else {
			inp.removeAttribute( 'multiple' );
		}
		return v;
	}

/* === Instance Fields === */

	/* the input in question */
	private var input : InputElement;

	/* the input, as an Element */
	private var inp : Element;

	/* the Signal fired when the input's value changes */
	private var changed : Signal<WebFileList>;
}
