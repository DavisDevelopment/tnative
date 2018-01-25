package tannus.node;

import tannus.async.Cb;
import tannus.node.Buffer;
import tannus.node.EventEmitter;
import tannus.node.WritableStream;
import haxe.Constraints.Function;

@:jsRequire('stream', 'Transform')
extern class Transform extends Duplex {
    public function new(?options: Dynamic):Void;

    @:noCompletion
    function _flush(callback: Function):Void;

    @:noCompletion
    function _transform(chunk:Buffer, encoding:String, callback:Cb<Dynamic>):Void;
}
