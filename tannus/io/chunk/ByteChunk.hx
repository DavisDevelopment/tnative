package tannus.io.chunk;

import tannus.io.ByteArray;
import tannus.ds.*;

import haxe.io.Bytes;

using Slambda;
using tannus.ds.ArrayTools;
using tannus.FunctionTools;
using tannus.async.OptionTools;
using tannus.async.Asyncs;

class ByteChunk extends ChunkBase implements ChunkObject {
    /* Constructor Function */
    public function new(data, from, to) {
        this.data = data;
        this.from = from;
        this.to = to;
    }

/* === Instance Methods === */

    public inline function getLength():Int {
        return (to - from);
    }

    public inline function getByte(index: Int):Byte {
        return Bytes.fastGet(data.getData(), from + index);
    }

    override function flatten(into: Array<ByteChunk>):Void {
        into.push( this );
    }

    public function getSlice(from:Int, to:Int):ByteChunk {
        if (to > this.getLength())
            to = this.getLength();
        if (from < 0)
            from = 0;
        return
            if (to <= from) null;
            else if (to == this.getLength() && from == 0) this;
            else new ByteChunk(data, this.from + from, to + this.from);
    }

    public function slice(from:Int, to:Int):Chunk {
        return switch getSlice(from, to) {
            case null: Chunk.EMPTY;
            case v: v;
        }
    }

    public function blitTo(target:Bytes, offset:Int):Void {
        target.blit(offset, data, from, getLength());
    }

    public function toBytes():Bytes {
        return data.sub(from, getLength());
    }

    public function toByteArray():ByteArray {
        return ByteArray.fromBytes(toBytes());
    }

    public function toString():String {
        return data.getString(from, getLength());
    }

    public static function of(b: Bytes):Chunk {
        if (b.length == 0)
            return Chunk.EMPTY;
        var ret = new ByteChunk(b, 0, b.length);
        return ret;
    }

/* === Instance Fields === */

    var data: Bytes;
    var from: Int;
    var to: Int;
}
