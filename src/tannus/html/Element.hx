package tannus.html;

import tannus.ds.Maybe;
import tannus.ds.Object;
import tannus.io.Ptr;
import tannus.geom.Point;
import tannus.geom.Rectangle;

import tannus.html.ElStyles;

import js.JQuery;

using Lambda;
@:forward
abstract Element (JQuery) from JQuery to JQuery {
	/* Constructor Function */
	public inline function new(jq : Dynamic):Void {
		this = new JQuery(jq);
	}

/* === Instance Fields === */

	/**
	  * Internal reference to [this], as an Element
	  */
	private var self(get, never):Element;
	private inline function get_self() return new Element(this);

	/**
	  * Determine whether any actual Elements are currently being referenced
	  */
	public var exists(get, never):Bool;
	private inline function get_exists() {
		return (this.length > 0);
	}

	/**
	  * textual value of [this] Element, as a field
	  */
	public var text(get, set):String;
	private inline function get_text() return (this.text());
	private inline function set_text(nt:String) {
		this.text( nt );
		return text;
	}

	/**
	  * Map-Like Access to the css-styles of [this] Element
	  */
	public var style(get, never):ElStyles;
	private function get_style():ElStyles {
		return new ElStyles(_cs.bind(_));
	}

	/* Utility Function, only used for the [style] field */
	private function _cs(args : Array<String>):String {
		var r:Maybe<String> = cs(args[0], args[1]);
		return (r || '');
	}

	/**
	  * More intuitive version of JQuery.css(k, v)
	  */
	private function cs(k:String, ?v:Maybe<String>):Maybe<String> {
		if (v) {
			this.css(k, v);
		}
		return this.css(k);
	}

	/**
	  * The position of [this] Element on the 'x' axis
	  */
	public var x(get, set):Float;
	private inline function get_x():Float {
		return (this.offset().left);
	}
	private inline function set_x(nx : Float):Float {
		cs('left', (nx + 'px'));
		return x;
	}

	/**
	  * The position of [this] Element on the 'y' axis
	  */
	public var y(get, set):Float;
	private inline function get_y():Float {
		return (this.offset().top);
	}
	private inline function set_y(ny : Float):Float {
		cs('top', (ny + 'px'));
		return y;
	}

	/**
	  * The position of [this] Element on the 'z' axis
	  */
	public var z(get, set):Float;
	private inline function get_z():Float {
		var msz:Maybe<String> = this.css('z-index');
		var mz:Float = Std.parseFloat(msz || '0');
		if (Math.isNaN(mz)) mz = 0;
		return mz;
	}
	private inline function set_z(nz : Float):Float {
		cs('z-index', (nz + ''));
		return z;
	}

	/**
	  * The width of [this] Element
	  */
	public var w(get, set):Float;
	private inline function get_w():Float {
		return (this.width() + 0.0);
	}
	private inline function set_w(v : Float):Float {
		this.width(Math.round(v));
		return w;
	}

	/**
	  * The position of [this] Element
	  */
	public var position(get, set):Point;
	private inline function get_position():Point {
		return new Point(x, y, z);
	}
	private inline function set_position(np : Point):Point {
		x = np.x;
		y = np.y;
		z = np.z;
		return position;
	}

/* === Instance Methods === */

	/**
	  * Get attribute
	  */
	@:arrayAccess
	public inline function get(key : String):Maybe<String> {
		return (this.attr(key));
	}

	/**
	  * Set attribute
	  */
	@:arrayAccess
	public inline function set(key:String, value:String):String {
		this.attr(key, value);
		return value;
	}

	/**
	  * Get the js.html.Element instance at [index]
	  */
	public inline function at(index : Int):js.html.Element {
		return this.get( index );
	}

/* === Operator Overloading === */

	/**
	  * Add [this] Element to another
	  */
	@:op(A + B)
	public inline function addToElement(other : Element):Element {
		return this.add( other );
	}

	/**
	  * Add [this] Element to an Array of Elements
	  */
	@:op(A + B)
	public inline function addToElementArray(other : Array<Element>):Element {
		return fromArray(toArray().concat(other));
	}

	/**
	  * Subtract [this] Element from another
	  */
	@:op(A - B)
	public inline function subFromElement(other : Element):Element {
		return (self - other.toArray());
	}

	/**
	  * Subtract [this] Element from an Array of Elements
	  */
	@:op(A - B)
	public inline function subFromElementArray(els : Array<Element>):Element {
		var res:Array<Element> = toArray().filter(function( e ) {
			return (els.has( e ));
		});

		var result:Element = new Element('');
		for (e in res) {
			result += e;
		}
		return result;
	}

/* === Type Casting === */

	/* To Array of ELements */
	@:to
	public inline function toArray():Array<Element> {
		return (this.toArray().map(function(e) return new Element(e)));
	}

	/* From Array of Elements */
	public static inline function fromArray(els : Array<Element>):Element {
		var el:Element = new Element('');
		for (e in els) el += e;
		return el;
	}

	/* To js.html.Element */
	@:to
	public inline function toHTMLElement():js.html.Element {
		return (at(0));
	}

	/* From String */
	@:from
	public static inline function fromString(q : String):Element {
		return new Element(q);
	}

	/* From js.html.Element */
	@:from
	public static inline function fromDOMElement(el : js.html.DOMElement):Element {
		return new Element( el );
	}
}
