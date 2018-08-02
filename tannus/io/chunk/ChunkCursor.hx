package tannus.io.chunk;

import tannus.io.ByteArray;
import tannus.ds.*;

import haxe.io.Bytes;

using Slambda;
using tannus.ds.ArrayTools;
using tannus.FunctionTools;
using tannus.async.OptionTools;
using tannus.async.Asyncs;

class ChunkCursor {
    /* Constructor Function */
    public function new():Void {
        //
    }

/* === Instance Methods === */

    function reset() {
        length = 0;
        currentPos = 0;
        currentByte = -1;
        curOffset = 0;

        for (p in parts)
            length += p.getLength();

        this.curPart = parts[this.curPartIndex = 0];
        if (this.curPart != null) {
            this.curLength = this.curPart.getLength();
            this.currentByte = this.curPart.getByte(0);
        }
    }

    public function left():Chunk {
        if (curPart == null) return Chunk.EMPTY;
        var left = [for (i in 0...curPartIndex) (parts[i] : Chunk)];
        left.push(curPart.slice(0, curOffset));
        return Chunk.join( left );
    }

    public function right():Chunk {
        if (curPart == null) return Chunk.EMPTY;
        var right = [for (i in curPartIndex...parts.length) (parts[i]:Chunk)];
        if (right.length > 0) {
            right[0] = curPart.slice(curOffset, curLength);
        }
        return Chunk.join( right );
    }

    public function flush() {
        var ret = left();
        prune();
        return ret;
    }

    public function sweep(len: Int) {
        var data = right().slice(0, len);
        moveBy( len );
        return data;
    }

    public inline function sweepTo(pos: Int)
        return sweep(pos - currentPos);

    public inline function moveBy(delta: Int)
        return moveTo(currentPos + delta);

    public function moveTo(position: Int) {
        if (length == 0) return 0;
        if (position > length) position = length - 1;
        if (position < 0) position = 0;

        this.currentPos = position;

        if (position == length) ffwd();
        else
            for (i in 0...parts.length) {
                var c = parts[i];
                switch c.getLength() {
                    case enough if (enough > position):
                        this.curPart = c;
                        this.curPartIndex = i;
                        this.curOffset = position;
                        this.curLength = c.getLength();
                        this.currentByte = c.getByte(position);
                        break;

                    case v:
                        position -= v;
                }
            }

        return this.currentPos;
    }

    function ffwd() {
        currentByte = -1;
        curLength = 0;
        curOffset = 0;
        curPart = null;
        curPartIndex = parts.length;
    }

    public function next():Bool {
        if (currentPos == length) 
            return false;

        currentPos++;
        if (currentPos == length) {
            ffwd();
            return false;
        }
        if (curOffset == curLength - 1) {
            curOffset = 0;
            curPart = parts[++curPartIndex];
            curLength = curPart.getLength();
            currentByte = curPart.getByte(0);
        }
        else {
            currentByte = curPart.getByte(++curOffset);
        }
        return true;
    }

    public inline function prune()
        shift();

    public function shift(?chunk: Chunk) {
        parts.splice(0, curPartIndex);
        switch parts[0] {
            case null:
            case chunk:
                switch chunk.getSlice(curOffset, curLength) {
                    case null:
                        parts.shift();

                    case rest:
                        parts[0] = rest;
                }
        }

        if (chunk != null)
            add( chunk );
        else
            reset();
    }

    public function clear() {
        parts = [];
        reset();
    }

    public function add(chunk: Chunk) {
        (chunk : ChunkObject).flatten( parts );
        reset();
    }

    public function clone():ChunkCursor {
        var ret = new ChunkCursor();
        ret.parts = this.parts.copy();
        ret.curPart = this.curPart;
        ret.curPartIndex = this.curPartIndex;
        ret.curOffset = this.curOffset;
        ret.curLength = this.curLength;
        ret.length = this.length;
        ret.currentPos = this.currentPos;
        ret.currentByte = this.currentByte;
        return ret;
    }

    public static function create(parts) {
        var ret = new ChunkCursor();
        ret.parts = parts;
        ret.reset();
        return ret;
    }

/* === Instance Fields === */

    public var length(default, null):Int = 0;
    public var currentPos(default, null):Int = 0;
    public var currentByte(default, null):Byte = -1;

    var parts: Array<ByteChunk>;
    var curPart: ByteChunk;
    var curPartIndex: Int = 0;
    var curOffset: Int = 0;
    var curLength: Int = 0;
}
