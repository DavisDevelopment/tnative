package tannus.io;

import haxe.macro.Expr;
import haxe.macro.Context;

/**
  * Abstract class which allows an Integer to behave as both an integer, and a single-character String, simultaneously
  */
abstract Byte (Int) from Int to Int {
	/* Constructor Function */
	public inline function new(n : Int):Void {
		assertValid(n);
		this = n;
	}

/* === Instance Fields === */

	/**
	  * internal reference to [this] as a Byte
	  */
	private var self(get, never):Byte;
	private inline function get_self():Byte {
		return cast this;
	}

	/**
	  * reference to [this] as an Int
	  */
	public var asint(get, set):Int;
	private inline function get_asint():Int {
		return this;
	}
	private inline function set_asint(n : Int):Int {
		assertValid(n);
		return (this = n);
	}

	/**
	  * reference to [this] as a String
	  */
	public var aschar(get, set):String;
	private inline function get_aschar():String {
		return String.fromCharCode(asint);
	}
	private inline function set_aschar(s : String):String {
		var n:Int = s.charCodeAt(0);
		assertValid(n);
		this = n;
		return aschar;
	}

/* === Instance Methods === */

	/**
	  * Tests whether [this] Byte would be a number in String form
	  */
	public inline function isNumeric():Bool {
		return (this >= 48 && this <= 57);
	}

	/**
	  * Tests whether [this] Byte would be a letter in String form
	  */
	public inline function isLetter():Bool {
		return ((this >= 65 && this <= 90) || (this >= 97 && this <= 122));
	}

	/**
	  * Tests whether [this] Byte would be alphanumeric in String form
	  */
	public inline function isAlphaNumeric():Bool {
		return (isNumeric() || isLetter());
	}

	/**
	  * Check whether [this] Byte is an uppercase Letter
	  */
	public inline function isUppercase():Bool {
		return (this >= 65 && this <= 90);
	}

	/**
	  * Check whether [this] Byte is a lowercase letter
	  */
	public inline function isLowercase():Bool {
		return (this >= 97 && this <= 122);
	}

	/**
	  * Tests whether [this] Byte would be a whitespace character in String form
	  */
	public inline function isWhiteSpace():Bool {
		return Lambda.has([9, 10, 11, 12, 13, 32], asint);
	}

	/**
	  * Tests whether [this] Byte is a line-breaking character
	  */
	public inline function isLineBreaking():Bool {
		return (this == 10 || this == 13);
	}

	/**
	  * Check whether [this] Byte is a punctuation mark
	  */
	public inline function isPunctuation():Bool {
		return Lambda.has([
			33, 44, 45, 46,
			58, 59, 53
		], asint);
	}

/* === Operator Overloading === */

	/**
	  * Equality Testing - Int
	  */
	@:op(A == B)
	public function equalsi(other : Int):Bool {
		return (this == other);
	}
	
	/**
	  * Equality Testing - String
	  */
	@:op(A == B)
	public function equalss(other : String):Bool {
		return (this == other.charCodeAt(0));
	}

	/**
	  * Repetition
	  */
	@:op(A * B)
	public function repeat(times : Int):String {
		var s:String = '';
		while (s.length < times) {
			s += aschar;
		}
		return s;
	}

/* === Type Casting === */

	/* To String */
	@:to
	public inline function toString():String {
		return aschar;
	}

	/* To Int */
	@:to
	public inline function toInt():Int {
		return asint;
	}

	#if java
	/* To java.lang.Byte */
	@:to
	public inline function toJavaByte():java.lang.Byte {
		var _i:Int = asint;
		return cast (untyped __java__('(byte) _i'));
	}
	#end

	@:from(String)
	public static inline function fromString(s : String):Byte {
		var b:Byte = 0;
		
		b.aschar = s;
		
		return b;
	}

/* === Class Methods === */

	/**
	  * Checks that the given integer is both a valid number, and finite
	  */
	private static function isValid(n : Int):Bool {
		return ((Std.is(n, Int)) && Math.isFinite(n) && !Math.isNaN(n));
	}

	/**
	  * Checks that [n] is valid, and if not, throws an error
	  */
	private static inline function assertValid(n : Int) {
		if (!isValid(n)) {
			throw 'Invalid Byte Value ($n)!';
		}
	}
}
