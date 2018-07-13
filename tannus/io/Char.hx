package tannus.io;

import tannus.ds.*;
import tannus.math.TMath.*;

import haxe.extern.EitherType as Either;
import haxe.macro.Expr;
import haxe.macro.Context;

using StringTools;
using tannus.ds.StringUtils;
using tannus.ds.ArrayTools;
using Lambda;
using tannus.math.TMath;
using haxe.macro.ExprTools;
using tannus.macro.MacroTools;

abstract Char (String) from String to String {
    /* Constructor Function */
    public inline function new(s: String):Void {
        this = sanitizeString( s );
    }

/* === Instance Methods === */

    public inline function compareTo(other: Char):Int {
        return haxe.Utf8.compare(this, other.toString());
    }

    @:op(A == B)
    public inline function equalsString(other: String):Bool {
        return (this == sanitizeString( other ));
    }

    public inline function isWhiteSpace():Bool {
        return isAny(9, 10, 11, 12, 13, 32);
    }

    public inline function isLineBreaking():Bool {
        return isAny(10, 13);
    }

    public inline function isLowerCase():Bool return lowerCaseLetterPattern.match( this );
    public inline function isUpperCase():Bool return upperCaseLetterPattern.match( this );
    public inline function isLetter():Bool return letterPattern.match( this );
    public inline function isNumeric():Bool return numericPattern.match( this );
    public inline function isAlphaNumeric():Bool return alphanumericPattern.match( this );

    public inline function toLowerCase():Char {
        return fromString(this.toLowerCase());
    }

    public inline function toUpperCase():Char {
        return fromString(this.toUpperCase());
    }

    @:op(A + B)
    public inline function plusInt(n: Int):Char {
        return (code + n);
    }

    @:op(A - B)
    public inline function minusInt(n: Int):Char {
        return (code - n);
    }

    @:op(A < B)
    public inline function lessThan(other: Char):Bool {
        return (compareTo( other ) < 0);
    }

    @:op(A > B)
    public inline function greaterThan(other: Char):Bool {
        return (compareTo( other ) > 0);
    }

    /**
      * checks for equality between [this] and any of the values in [rest...]
      */
	public macro function isAny(self:ExprOf<Char>, rest:Array<Expr>):ExprOf<Bool> {
	    var strings:Array<ExprOf<String>> = new Array();
	    for (e in rest) {
	        switch ( e.expr ) {
                case EConst(Constant.CString( s )):
                    if (s.length == 1) {
                        strings.push( e );
                    }
                    else {
                        for (i in 0...s.length) {
                            strings.push(macro $v{s.charAt( i )});
                        }
                    }

                case EConst(Constant.CInt( v )):
                    strings.push(macro String.fromCharCode(Std.parseInt($v{v})));

                case EConst(Constant.CIdent(_)):
                    strings.push(macro Std.string($e).charAt( 0 ));

                default:
                    throw 'Error: Unexpected ${e}';
	        }
	    }

	    inline function expr(e: ExprDef):Expr {
	        return {
	            pos: Context.currentPos(),
	            expr: e
	        };
        }

	    function or(i: Array<Expr>):Expr {
	        return expr(EBinop(Binop.OpBoolOr, i.shift(), (i.length >= 2 ? or( i ) : i.shift())));
	    }

	    return or(strings.map(function(num) {
	        return macro ($self.equalsString( $num ));
	    }));
	}

/* === Casting Methods === */

    @:from
    public static inline function fromString(s: String):Char {
        return new Char( s );
    }

    @:to
    public inline function toString():String return (this : String);

    @:from
    public static inline function fromInt(i: Int):Char {
        return fromString(String.fromCharCode(sanitizeInt( i )));
    }

    @:to
    public inline function toInt():Int return StringTools.fastCodeAt(this, 0);

/* === Utility Methods === */

    private static function validateString(s: String):Void {
        // [s] is not a String
        if (!(s is String)) {
            throw CharException.CEInvalidType;
        }
        // [s] is null or has no content
        else if (s.empty()) {
            throw CharException.CEEmptyString;
        }

        // [s] must be valid
        return ;
    }

    private static inline function ensureIsValidString(s: String):String {
        validateString( s );
        return s;
    }

    public static function sanitizeString(s: String):String {
        if (s.length > 1) {
            s = s.charAt( 0 );
        }
        return ensureIsValidString( s );
    }

    private static inline function validateInt(i: Null<Int>):Void {
        if (i == null || !i.isFinite() || i.isNaN() || !i.inRange(0, 0xFFFD)) {
            throw CharException.CEInvalidCharCode;
        }
        return ;
    }

    private static inline function ensureIsValidInt(i: Null<Int>):Int {
        validateInt( i );
        if (i == null)
            i = 0;
        return i;
    }

    public static inline function sanitizeInt(i: Int):Int {
        return ensureIsValidInt(int(abs( i )));
    }

/* === Instance Fields === */

    public var code(get, never):Int;
    private function get_code() return toInt();

/* === Static Vars === */

    private static var upperCaseLetterPattern:EReg = {~/[A-Z]/;};
    private static var lowerCaseLetterPattern:EReg = {~/[a-z]/;};
    private static var numericPattern:EReg = {~/[0-9]/;};
    private static var letterPattern:EReg = {~/[A-Za-z]/;};
    private static var alphanumericPattern:EReg = {~/[A-Za-z0-9]/;};
}

enum CharException {
    CEEmptyString;
    CENullChar;
    CEInvalidCharCode;
    CEInvalidType;
}
