package tannus.nore;

import tannus.nore.ORegEx;

import tannus.ds.TwoTuple;

/**
  * abstract class to represent a Selector String
  */
abstract Selector<T> (TwoTuple<String, SelectorFunction<T>>) {
	/* Constructor Function */
	public inline function new(s : String):Void {

		this = new TwoTuple(s, ORegEx.compile(s));
	}

/* === Instance Fields === */
	
	/**
	  * Reference to the selector-string of [this] Selector
	  */
	public var selector(get, never) : String;
	private inline function get_selector():String {
		return (this.one);
	}

	/**
	  * Reference to the selector-function of [this] Selector
	  */
	public var func(get, never) : SelectorFunction<T>;
	private inline function get_func():SelectorFunction<T> {
		return (this.two);
	}

/* === Instance Methods === */

	/**
	  * Create and return a "clone" of [this] Selector
	  */
	public inline function clone():Selector<T> {
		return (new Selector(selector));
	}

	/**
	  * Validate [o] with Selector
	  */
	public inline function test(o : T):Bool {
		return (func( o ));
	}

	/**
	  * Filter out all elements [list] which don't validate
	  */
	public inline function filter(list : Array<T>):Array<T> {
		return (list.filter(func));
	}

	/**
	  * Cast [this] Selector to a String
	  */
	public inline function toString():String {
		return ('Selector($selector)');
	}

/* === Operators === */

	/**
	  * Create and return this inverse of [this] Selector
	  */
	@:op( !A )
	public inline function invert():Selector<T> {
		return (new Selector('!($selector)'));
	}

	/**
	  * Create and return a combination of [one] and [other]
	  */
	@:op(A + B)
	public static inline function add <T> (one:Selector<T>, other:Selector<T>):Selector<T> {
		return (new Selector('(${one.selector})(${other.selector})'));
	}

	/**
	  * "subtract" [other] from [one]
	  */
	@:op(A - B)
	public static inline function minus <T> (one:Selector<T>, other:Selector<T>):Selector<T> {
		return (new Selector('(${one.selector}) !(${other.selector})'));
	}

/* === Implicit Casting === */

	@:from
	public static inline function fromString<T>(s : String):Selector<T> {
		return new Selector(s);
	}
}



/**
  * private typedef representing a SelectorFunction
  */
private typedef SelectorFunction<T> = T->Bool;
