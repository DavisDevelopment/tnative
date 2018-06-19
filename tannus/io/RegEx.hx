package tannus.io;

import tannus.ds.Maybe;

#if js
import js.RegExp;
#end

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;
using tannus.FunctionTools;

@:forward
/* Abstraction layer on top of the EReg type */
abstract RegEx (EReg) from EReg to EReg {
	/* Constructor Function */
	public inline function new(pattern : EReg):Void {
		this = pattern;
	}

/* === Instance Methods === */

	/**
	  * Get an Array of all substrings of [text] which fit [this] pattern
	  */
	public function matches(text : String):Array<Array<String>> {
		return reduce(text, function(self:RegEx, all:Array<Array<String>>) {
		    all.push(groups());
		    return all;
		}, new Array<Array<String>>());
	}

    /**
      * calculate list of 'match'es
      */
	public function search(text:String):Array<RegExMatch> {
	    return reduce(text, function(self:RegEx, matches:Array<RegExMatch>) {
	        matches.push(currentMatch( text ));
	        return matches;
	    }, new Array<RegExMatch>());
	}

    /**
      * get list of matched capture-groups for the current match
      (the first item in the list is the whole matched substring)
      */
	public function groups():Array<String> {
	    var parts:Array<String> = new Array();
	    var index:Int = 0;
	    while ( true ) {
	        try {
	            var g = this.matched(index++);
	            if (g == null)
	                break;
	            parts.push( g );
	        }
	        catch (error: Dynamic) {
	            break;
	        }
	    }
	    return parts;
	}

    /**
      * get [this]'s current Match object
      */
	public function currentMatch(txt: String):Null<RegExMatch> {
	    var pos = this.matchedPos();
	    return new RegExMatch(this, txt, pos.pos, pos.len, groups());
	}

    /**
      * same as EReg.map, but [f] receives a RegEx instance as argument
      */
	public inline function map(text:String, f:RegEx->String):String {
	    return this.map(text, f);
	}

	/**
	  * map by match
	  */
	public inline function mmap(text:String, f:RegExMatch->String):String {
	    return map(text, function(self: RegEx) {
	        return f(currentMatch( text ));
	    });
	}

    /**
      * iterate over each match
      */
	public inline function iter(text:String, f:RegEx->Void):Void {
	    map(text, function(me) {
	        f( me );
	        return '';
	    });
	}

    /**
      * 
      */
	public inline function reduce<TAcc>(text:String, f:RegEx->TAcc->TAcc, acc:TAcc):TAcc {
	    iter(text, function(self) {
	        acc = f(self, acc);
	    });
	    return acc;
	}

	/**
	  * Cast to a (String -> Bool)
	  */
	@:to
	public function toTester():String->Bool {
		return (this.match.bind(_));
	}

#if js

    var re(get, never):RegExp;
    inline function get_re() return cast(@:privateAccess this.r, RegExp);

    public function toString():String {
        return '~/${getSource()}/${getFlags()}';
    }

    public inline function getSource():String {
        return re.source;
    }

    public inline function getFlags():String {
        return Std.string((untyped re).flags);
    }

    @:op(A || B)
    public static function combine_or(left:RegEx, right:RegEx):RegEx {
        if (left.getFlags() != right.getFlags()) {
            throw 'Error: EReg flags must be the same for left and right operands';
        }
        else {
            return new RegEx(new EReg(('(?:${left.getSource()})|(?:${right.getSource()})'), left.getFlags()));
        }
    }

#end
}

class RegExMatch {
    public var regex(default, null): RegEx;
    public var string(default, null): String;
    public var start(default, null): Int;
    public var end(default, null): Int;
    public var groups(default, null): Array<String>;

    public inline function new(re:RegEx, s:String, x:Int, y:Int, g:Array<String>) {
        regex = re;
        string = s;
        start = x;
        end = y;
        groups = g;
    }
}

private typedef ERegPos = {pos:Int, len:Int};
