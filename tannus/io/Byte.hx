package tannus.io;

import haxe.macro.Expr;
import haxe.macro.Context;

import tannus.math.TMath.*;

using StringTools;
using tannus.ds.StringUtils;
using tannus.macro.MacroTools;
using Lambda;
using tannus.math.TMath;

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
	private inline function get_asint():Int { return this; }
	private inline function set_asint(n : Int):Int {
		assertValid(n);
		return (this = n);
	}

	/**
	  * reference to [this] as a String
	  */
	public var aschar(get, set):String;
	private inline function get_aschar():String { return String.fromCharCode(asint); }
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
	    return inRange(48, 57);
		//return (this >= 48 && this <= 57);
	}

	/**
	  * Tests whether [this] Byte would be a letter in String form
	  */
	public inline function isLetter():Bool {
	    return (inRange(65, 90) || inRange(97, 122));
		//return ((this >= 65 && this <= 90) || (this >= 97 && this <= 122));
	}

	/**
	  * Tests whether [this] Byte would be alphanumeric in String form
	  */
	public inline function isAlphaNumeric():Bool { return (isNumeric() || isLetter()); }

	/**
	  * Check whether [this] Byte is an uppercase Letter
	  */
	public inline function isUppercase():Bool {
	    return inRange(65, 90);
		//return (this >= 65 && this <= 90);
	}

	/**
	  * Check whether [this] Byte is a lowercase letter
	  */
	public inline function isLowercase():Bool {
	    return inRange(97, 122);
		//return (this >= 97 && this <= 122);
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

	/**
	  * convert letter-byte into its upper-case form
	  */
	public inline function toUpperCase():Byte {
	    return new Byte(if (isLowercase()) (this - 32) else this);
	}

	/**
	  * convert letter-byte into its lower-case form
	  */
	public inline function toLowerCase():Byte {
	    return new Byte(if (isLowercase()) (this - 32) else this);
	}

/* === Operator Overloading === */

	/**
	  * Equality Testing - Int
	  */
	@:op(A == B)
	public inline function equalsi(other : Int):Bool {
		return (this == other);
	}
	
	/**
	  * Equality Testing - String
	  */
	@:op(A == B)
	public inline function equalss(other : String):Bool {
		//return (this == other.charCodeAt(0));
		return (this == other.fastCodeAt(0));
	}

	public macro function equalsChar(self:ExprOf<Byte>, c:ExprOf<String>):ExprOf<Bool> {
		var i : ExprOf<Int>;
		if (c.isConstant()) {
			i = macro $c.code;
		}
		else {
			i = macro $c.charCodeAt( 0 );
		}
		return macro ($self == $i);
	}

	public macro function ec(self:ExprOf<Byte>, c:ExprOf<String>):ExprOf<Bool> {
	    var i:ExprOf<Int>;
	    if (c.isConstant()) {
	        i = macro $c.code;
	    }
        else {
            i = macro StringTools.fastCodeAt($c, 0);
        }
        return macro ($self == $i);
	}

	public macro function isAny(self:ExprOf<Byte>, rest:Array<Expr>):ExprOf<Bool> {
	    var nums:Array<ExprOf<Int>> = new Array();
	    for (e in rest) {
	        switch ( e.expr ) {
                case EConst(Constant.CString(s)):
                    if (s.length == 1)
                        nums.push(macro $e.code);
                    else {
                        for (i in 0...s.length) {
                            nums.push(macro $v{s.charCodeAt(i)});
                        }
                    }

                case EConst(Constant.CInt(_)):
                    nums.push(macro $e);

                case EConst(Constant.CIdent(_)):
                    nums.push(macro StringTools.fastCodeAt($e, 0));

                default:
                    throw 'Error: Unexpected ${e}';
	        }
	    }
	    inline function expr(e:ExprDef):Expr return {pos:Context.currentPos(),expr:e};
	    function or(i : Array<Expr>):Expr {
	        return expr(EBinop(Binop.OpBoolOr, i.shift(), (i.length>=2?or(i):i.shift())));
	    }
	    return or(nums.map(function(num) {
	        return macro ($self == $num);
	    }));
	}

	/**
	  * Repetition
	  */
	@:op(A * B)
	public inline function repeat(times : Int):String {
		return aschar.times(times);
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
		return new Byte(s.charCodeAt(0));
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
