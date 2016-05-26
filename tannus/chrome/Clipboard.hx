package tannus.chrome;

import tannus.html.Win;
import tannus.io.*;
import tannus.ds.*;

import js.html.InputElement;
import js.html.TextAreaElement;

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
		var i = inp();
		i.focus();
		doc.execCommand( 'paste' );
		var result = i.value;
		i.remove();
		return result;
	}

	/**
	  * write clipboard data
	  */
	public static function setData(s : String):Void {
		var i = inp();
		i.focus();
		i.value = s;
		doc.execCommand( 'selectAll' );
		i.select();
		doc.execCommand('copy', false, null);
		i.remove();
	}

	private static function inp():ClipboardElement {
		var i:ClipboardElement = cast doc.createElement('textarea');
		doc.body.appendChild( i );
		return i;
	}

	private static var win(get, never):Win;
	private static inline function get_win():Win {
		return Win.current;
	}

	private static var doc(get, never):js.html.HTMLDocument;
	private static inline function get_doc():js.html.HTMLDocument {
		return win.document;
	}

	/*
	private static var inp(get, never):ClipboardElement;
	private static function get_inp():ClipboardElement {
		if (_inp == null) {
			_inp = cast doc.createElement( 'textarea' );
			doc.body.appendChild( _inp );
		}
		return _inp;
	}
	*/

	/*
	private static function __init__():Void {
		_inp = null;
		bg = null;

		Runtime.getBackgroundPage(function( bgp ) {
			if (Win.current != bgp) {
				bg = bgp;
				_inp = null;
			}
		});
	}
	*/

	//private static var _inp:Null<ClipboardElement>;
	//private static var bg : Null<Win>;
}

private typedef ClipboardElement = TextAreaElement;
