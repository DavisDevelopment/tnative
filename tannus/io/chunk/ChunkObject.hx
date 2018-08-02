package tannus.io.chunk;

import tannus.io.ByteArray;
import tannus.ds.*;

import haxe.io.Bytes;

using Slambda;
using tannus.ds.ArrayTools;
using tannus.FunctionTools;
using tannus.async.OptionTools;
using tannus.async.Asyncs;

interface ChunkObject {
    function getCursor():ChunkCursor;
    function flatten(into: Array<ByteChunk>):Void;
    function slice(from:Int, to:Int):Chunk;
    function getLength():Int;
    function toString():String;
    function toBytes():Bytes;
    function toByteArray():ByteArray;
    function blitTo(target:Bytes, offset:Int):Void;
}
