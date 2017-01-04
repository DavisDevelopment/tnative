package tannus.nw;

import tannus.io.*;
import tannus.html.Win;
import tannus.html.fs.*;

import js.html.InputElement;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;
using Slambda;
using tannus.ds.AnonTools;

class FileInput {
	/* Constructor Function */
	public function new():Void {
		inputElement = Win.current.document.createInputElement();
		inputElement.with({
			type = 'file';
		});

		cancelEvent = new VoidSignal();
		changeEvent = new Signal2();

		__initevents();
	}

/* === Instance Methods === */

	/**
	  * initialize event listeners on [this] Input
	  */
	private function __initevents():Void {
		/*
		e.addEventListener('change', function(event : Dynamic) {
			var files:WebFileList = new WebFileList( e.files );
			var value:String = e.value;

			changeEvent.call(value, files);
		});
		*/

		e.addEventListener('click', function(event) {
			Win.current.document.body.onfocus = function(evt) {
				(untyped __js__('process')).nextTick(function() {
					if (e.value.length == 0) {
						cancelEvent.call();
					}
					else {
						var value:String = e.value;
						var files:WebFileList = new WebFileList( e.files );
						changeEvent.call(value, files);
					}
				});
			};
		});
	}

	/**
	  * trigger a 'click' on [this] Input
	  */
	public inline function click():Void {
		e.click();
	}

/* === Computed Instance Fields === */

	private var e(get, never):InputElement;
	private inline function get_e():InputElement return inputElement;

	public var multiple(get, set):Bool;
	private inline function get_multiple():Bool return e.hasAttribute('multiple');
	private function set_multiple(v : Bool):Bool {
		if ( v )
			e.setAttribute('multiple', '');
		else
			e.removeAttribute('multiple');
		return multiple;
	}

	public var directory(get, set):Bool;
	private inline function get_directory():Bool return e.hasAttribute('nwdirectory');
	private function set_directory(v : Bool):Bool {
		if ( v )
			e.setAttribute('nwdirectory', '');
		else
			e.removeAttribute('nwdirectory');
		return directory;
	}

	public var save(get, set):Bool;
	private inline function get_save():Bool return e.hasAttribute('nwsaveas');
	private function set_save(v : Bool):Bool {
		if ( v ) {
			e.setAttribute('nwsaveas', '');
		}
		else {
			e.removeAttribute('nwsaveas');
		}
		return save;
	}

	public var saveName(get, set):Null<String>;
	private function get_saveName():Null<String> {
		if (e.hasAttribute('nwsaveas')) {
			var nwsa:Null<String> = e.getAttribute( 'nwsaveas' );
			if (nwsa != null && nwsa.trim().length == 0) nwsa = null;
			return nwsa;
		}
		else return null;
	}
	private function set_saveName(v : Null<String>):Null<String> {
		e.setAttribute('nwsaveas', v);
		return saveName;
	}

/* === Instance Fields === */

	public var inputElement : InputElement;
	public var changeEvent : Signal2<String, WebFileList>;
	public var cancelEvent : VoidSignal;
}
