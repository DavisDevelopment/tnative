package tannus.io.impl;

import tannus.io.RegEx;

using StringTools;
using tannus.ds.StringUtils;

class RegExMatch {
	/* Constructor Function */
	public function new(re:RegEx, strings:Array<String>, pos:Pos, groups:Array<String>):Void {
		this.re = re;
		this.source = strings[0];
		this.text = strings[1];
		this.pos = pos;
		this.groups = groups;
	}

/* === Instance Fields === */

	public var re : RegEx;
	public var source : String;
	public var text : String;
	public var groups : Array<String>;
	public var pos : Pos;
}

typedef Pos = {
	start : Int,
	len   : Int
};
