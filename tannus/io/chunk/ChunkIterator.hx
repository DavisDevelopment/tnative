package tannus.io.chunk;

import tannus.io.ByteArray;
import tannus.ds.*;

import haxe.io.Bytes;

using Slambda;
using tannus.ds.ArrayTools;
using tannus.FunctionTools;
using tannus.async.OptionTools;
using tannus.async.Asyncs;

class ChunkIterator {
    public inline function new(target) {
        this.target = target;
        this._hasNext = target.length > target.currentPos;
    }

/* === Instance Methods === */

    public inline function hasNext():Bool {
        return _hasNext;
    }

    public inline function next() {
        var ret = target.currentByte;
        _hasNext = target.next();
        return ret;
    }

/* === Instance Fields === */

    var target: ChunkCursor;
    var _hasNext: Bool;
}
