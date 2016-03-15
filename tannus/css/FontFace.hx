package tannus.css;

import tannus.css.Rule;
import tannus.css.Value;

abstract FontFace (Rule) from Rule to Rule {
	/* Constructor Function */
	public function new(sheet:StyleSheet, family:String, source:String):Void {
		this = new Rule(sheet, '@font-face');
		this.set('font-family', family);
		this.set('src', 'url("$source")');
	}

/* === Instance Fields === */

	/* the 'font-family' property */
	public var family(get, set):String;
	private inline function get_family():String {
		return this.get( 'font-family' );
	}
	private inline function set_family(v : String):String {
		this.set('font-family', v);
		return family;
	}

	/* the source from which [this] FontFace was loaded */
	public var source(get, set):String;
	private function get_source():String {
		switch ( this.property( 'src' ).values[0] ) {
			case Value.VCall('url', [Value.VString( src )]):
				return src;
			default:
				throw 'Unabled to get the "src" of the FontFace';
				return '';
		}
	}
	private function set_source(v : String):String {
		this.set('src', 'url("$v")');
		return v;
	}
}
