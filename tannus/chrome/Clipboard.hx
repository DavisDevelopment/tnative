package tannus.chrome;

import tannus.html.Win;
import tannus.io.*;
import tannus.ds.*;

import js.html.InputElement;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;

@:expose( 'clipboard' )
class Clipboard {
	/**
	  * read and return clipboard-data
	  */
	public static function getData():String {
		inp.focus();
		inp.value = '';
		doc.execCommand( 'paste' );
		return inp.value;
	}

	/**
	  * write clipboard data
	  */
	public static function setData(s : String):Void {
		inp.focus();
		inp.value = s;
		inp.select();
		inp.selectionStart = 0;
		inp.selectionEnd = s.length;
		doc.execCommand( 'copy' );
		inp.value = '';
	}

	private static var doc(get, never):js.html.HTMLDocument;
	private static inline function get_doc() return Win.current.document;

	private static var inp(get, never):InputElement;
	private static function get_inp():InputElement {
		if (_inp == null) {
			_inp = doc.createInputElement();
		}
		return _inp;
	}

	private static var _inp:Null<InputElement> = null;
}
