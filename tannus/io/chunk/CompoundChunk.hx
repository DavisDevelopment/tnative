package tannus.io.chunk;

import tannus.io.ByteArray;
import tannus.ds.*;

import haxe.io.Bytes;

using Slambda;
using tannus.ds.ArrayTools;
using tannus.FunctionTools;
using tannus.async.OptionTools;
using tannus.async.Asyncs;

class CompoundChunk extends ChunkBase implements ChunkObject {
    /* Constructor Function */
    public function new(l:Chunk, r:Chunk):Void {
        left = l;
        right = r;
        split = left.length;
        length = split + right.length;
    }

/* === Instance Methods === */

    public function getLength():Int
        return this.length;

    override function flatten(into: Array<ByteChunk>) {
        (left : ChunkObject).flatten( into );
        (right : ChunkObject).flatten( into );
    }

    public function slice(from:Int, to:Int):Chunk {
        return left.slice(from, to).concat(right.slice(from - split, to - split));
    }

    public function blitTo(target:Bytes, offset:Int):Void {
        left.blitTo(target, offset);
        right.blitTo(target, offset + split);
    }

    public function toBytes():Bytes {
        var ret = Bytes.alloc( this.length );
        blitTo(ret, 0);
        return ret;
    }

    public function toByteArray():ByteArray {
        return ByteArray.fromBytes(toBytes());
    }

    public function toString():String {
        return toBytes().toString();
    }

/* === Instance Fields === */

    var left: Chunk;
    var right: Chunk;

    var split: Int;
    var length: Int;
}
