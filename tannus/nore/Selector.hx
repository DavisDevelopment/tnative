package tannus.nore;

import tannus.ds.Object;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;

@:forward
abstract Selector (CSelector) from CSelector to CSelector {
	/* Constructor Function */
	public inline function new(s : String):Void {
		this = new CSelector( s );
	}

/* === Instance Methods === */

	/**
	  * Invert [this]
	  */
	@:op( !A )
	public inline function invert():Selector return this.invert();

	/* add [this] and [other] */
	@:op(A + B)
	public inline function sum(other : Selector):Selector return this.sum(other);

	/* subtract [this] and [other] */
	@:op(A - B)
	public inline function diff(other : Selector):Selector return this.diff(other);

	/**
	  * Convert [this] to a predicate function
	  */
	@:to
	public inline function toPredicate():Dynamic->Bool {
		return this.f;
	}

	/**
	  * Convert [this] to a String
	  */
	@:to
	public inline function toString():String return this.toString();

	/**
	  * Create a Selector from a String implicitly
	  */
	@:from
	public static inline function fromString(s : String):Selector {
		return new Selector( s );
	}
}

class CSelector {
	/* Constructor Function */
	public function new(sel : String):Void {
		selector = sel;
		f = ORegEx.compile( sel );
	}

/* === Instance Methods === */

	/**
	  * Test an Object against [this] Selector
	  */
	public function test(o : Dynamic):Bool {
		return f( o );
	}

	/**
	  * Filter an Array by [this] Selector
	  */
	public function filter<T>(list : Array<T>):Array<T> {
		return list.filter( f );
	}

	/**
	  * Create and return a clone of [this]
	  */
	public function clone():Selector {
		return new Selector(selector);
	}

	/**
	  * Convert [this] to a String
	  */
	public function toString():String {
		return 'Selector($selector)';
	}

	/**
	  * Create and return the opposite of [this] Selector
	  */
	public function invert():Selector {
		return new Selector('!($selector)');
	}

	/**
	  * Create and return the sum of [this] and [other]
	  */
	public function sum(other : Selector):Selector {
		return new Selector(selector + other.selector);
	}

	/**
	  * Create and return the 'difference' between [this] and [other]
	  */
	public function diff(other : Selector):Selector {
		return new Selector(selector + other.invert().selector);
	}

/* === Instance Fields === */

	public var selector : String;
	public var f : CheckFunction;
}
