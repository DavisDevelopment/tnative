package tannus.sys;

import tannus.io.RegEx;

using StringTools;
using tannus.ds.StringUtils;

abstract Mime (String) from String to String {
	/* Constructor Function */
	public inline function new(m : String):Void {
		this = m;
	}

/* === Instance Fields === */

	/* primary type */
	public var type(get, never):String;
	private inline function get_type() return getMainType();

	/* sub type */
	public var subtype(get, never):Null<String>;
	private function get_subtype():Null<String> {
		var st = getSubType();
		if (st == null)
			return null;
		return st.after('.').before('+');
	}

/* === Instance Methods === */

	/* Get the segments of [this] Mime Type */
	public function getSegments():Array<String> {
		var res:Array<String> = new Array();
		res = res.concat(this.split('/'));
		var last:String;

		if (res.length == 2) {
			//- extract "tree" types
			last = res.pop();
			var subs = last.split('.');
			res = res.concat( subs );

			//- extract "suffixes"
			last = res.pop();
			if (last.has('+')) {
				var suff = last.split('+');
				res = res.concat( suff );
			}
			else
				res.push( last );
		}

		return res;
	}

	/* Get the main type */
	public inline function getMainType():String {
		return (this.has('/') ? this.substring(0, this.indexOf('/')) : this);
	}

	/* get the sub-type */
	public inline function getSubType():Null<String> {
		return (this.has('/') ? this.substring(this.indexOf('/')+1) : null);
	}

	/* get the sub-type tree */
	public function getTree():Null<String> {
		var st:Null<String> = getSubType();
		if (st == null)
			return null;
		else {
			if (st.has('.')) {
				return st.substring(0, st.indexOf('.'));
			}
			else return null;
		}
	}
}
