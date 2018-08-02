package tannus.io;

import tannus.io.ByteArray;
import tannus.ds.*;

import haxe.io.Bytes;

import tannus.io.chunk.*;

using Slambda;
using tannus.ds.ArrayTools;
using tannus.FunctionTools;
using tannus.async.OptionTools;
using tannus.async.Asyncs;

abstract Chunk (ChunkObject) from ChunkObject to ChunkObject {
/* === Instance Methods === */

    public inline function cursor():ChunkCursor {
        return this.getCursor();
    }

    public inline function slice(from:Int, to:Int):Chunk {
        return this.slice(from, to);
    }

    public inline function blitTo(target:Bytes, offset:Int)
        return this.blitTo(target, offset);

    public inline function toHex():String {
        return this.toBytes().toHex();
    }

    @:to
    public inline function toString():String {
        return this.toString();
    }

    @:to
    public inline function toBytes():Bytes {
        return this.toBytes();
    }

    @:to
    public inline function toByteArray():ByteArray {
        return this.toByteArray();
    }

    public function concat(that: Chunk) {
        return switch [length, that.length] {
            case [0, 0]: EMPTY;
            case [0, _]: that;
            case [_, 0]: this;
            case _: new CompoundChunk(this, that);
        }
    }

/* === Instance Fields === */

    public var length(get, never): Int;
    inline function get_length() return this.getLength();

/* === Casting / Factory Methods === */

    public static function join(chunks: Array<Chunk>) {
        return switch chunks {
            case null | []: EMPTY;
            case [v]: v;
            case v:
                var ret = v[0] & v[1];
                for (i in 2...v.length)
                    ret = ret & v[i];
                ret;
        }
    }

    @:from
    public static function ofBytes(b: Bytes):Chunk {
        return (ByteChunk.of( b ) : ChunkObject);
    }

    @:from
    public static inline function ofByteArray(b: ByteArray):Chunk {
        return ofBytes( b );
    }

    @:from
    public static inline function ofString(s: String):Chunk {
        return ofBytes(Bytes.ofString( s ));
    }

    @:op(a & b)
    static function catChunk(a:Chunk, b:Chunk):Chunk {
        return a.concat( b );
    }

    @:op(a & b)
    static function rcatString(a:Chunk, b:String):Chunk {
        return catChunk(a, b);
    }

    @:op(a & b)
    static function lcatString(a:String, b:Chunk):Chunk {
        return catChunk(a, b);
    }

    @:op(a & b)
    static function lcatBytes(a:Bytes, b:Chunk):Chunk {
        return catChunk(a, b);
    }

    @:op(a & b)
    static function rcatBytes(a:Chunk, b:Bytes):Chunk {
        return catChunk(a, b);
    }

    @:op(a & b)
    static function lcatByteArray(a:ByteArray, b:Chunk):Chunk {
        return catChunk(a, b);
    }

    @:op(a & b)
    static function rcatByteArray(a:Chunk, b:ByteArray):Chunk {
        return catChunk(a, b);
    }

    public static var EMPTY(default, null):Chunk = ((new EmptyChunk() : ChunkObject) : Chunk);
}
