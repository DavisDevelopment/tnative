package tannus.io.chunk;

import tannus.io.ByteArray;
import tannus.ds.*;

import haxe.io.Bytes;

using Slambda;
using tannus.ds.ArrayTools;
using tannus.FunctionTools;
using tannus.async.OptionTools;
using tannus.async.Asyncs;

class ChunkBase {
    var flattened: Array<ByteChunk>;

    public function getCursor():ChunkCursor {
        if (flattened == null)
            flatten(this.flattened = []);
        return ChunkCursor.create(flattened.copy());
    }

    public function flatten(into: Array<ByteChunk>):Void {}
}
