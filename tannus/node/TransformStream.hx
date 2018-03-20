package tannus.node;

import tannus.async.Cb;

import tannus.node.Buffer;
import tannus.node.EventEmitter;
import tannus.node.WritableStream;
import tannus.node.ReadableStream;
import tannus.node.DuplexStream;

import haxe.Constraints.Function;

@:jsRequire('stream', 'Transform')
extern class TransformStream <I, O> extends DuplexStream <I, O> {
    public function new(?options: TransformStreamOptions):Void;

    @:noCompletion
    function _flush(callback: Function):Void;

    @:noCompletion
    function _transform(chunk:O, encoding:Null<String>, callback:Cb<Dynamic>):Void;
}

typedef TransformStreamOptions = {
    >DuplexStreamOptions,

    ?transform: Function,
    ?flush: Function
};

typedef SymmetricalTransformStream<T> = TransformStream<T, T>;
