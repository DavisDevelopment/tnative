package tannus.io.chunk;

import tannus.io.ByteArray;
import tannus.ds.*;

import haxe.io.Bytes;

using Slambda;
using tannus.ds.ArrayTools;
using tannus.FunctionTools;
using tannus.async.OptionTools;
using tannus.async.Asyncs;

class EmptyChunk extends ChunkBase implements ChunkObject {
    public function new() {}
    public function getLength():Int return 0;
    public function slice(from:Int, to:Int):Chunk return this;
    public function blitTo(target:Bytes, offset:Int):Void {}
    public function toString():String return '';
    public function toBytes():Bytes return EMPTY;
    public function toByteArray():ByteArray return ByteArray.fromBytes(toBytes());

    static var EMPTY = Bytes.alloc(0);
}
