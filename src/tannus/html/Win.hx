package tannus.html;

import js.Browser.window in win;
import js.html.Window in CWin;

import tannus.ds.Object;
import tannus.ds.Maybe;
import tannus.ds.Range;
import tannus.io.Ptr;
import tannus.io.Signal;

using StringTools;
using Lambda;

@:forward
abstract Win (CWin) from CWin to CWin {
	/* Constructor Function */
	public inline function new(?w:CWin):Void {
		this = ((w != null) ? w : win);
	}
}
