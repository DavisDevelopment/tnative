package tannus.nlp;

using StringTools;
using tannus.ds.StringUtils;

@:forward(length)
abstract Word (String) from String {
	/* Constructor Function */
	public inline function new(s : String):Void {
		this = s;
	}

/* === Instance Methods === */

	/* convert to lowercase */
	public inline function lower():Word {
		return new Word(this.toLowerCase());
	}

	/* convert to uppercase */
	public inline function upper():Word {
		return new Word(this.toUpperCase());
	}

	/* capitalize [this] Word */
	public inline function capitalize():Word {
		return new Word(this.capitalize());
	}

	/* convert to a String */
	@:to
	public inline function toString():String {
		return this;
	}

/* === Instance Fields === */

	/* check whether [this] Word is lowercase */
	public var islower(get, never):Bool;
	private inline function get_islower():Bool {
		return (this.toLowerCase() == this);
	}

	/* check whether [this] Word in uppercase */
	public var isupper(get, never):Bool;
	private inline function get_isupper():Bool {
		return (this.toUpperCase() == this);
	}

	/* check whether [this] Word is capitalized */
	public var iscapitalized(get, never):Bool;
	private inline function get_iscapitalized():Bool {
		return (this.capitalize() == this);
	}
}
