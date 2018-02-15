package tannus.node;

import tannus.node.Buffer;
import tannus.node.EventEmitter;
import tannus.node.WritableStream;
import haxe.Constraints.Function;

@:jsRequire('stream', 'PassThrough')
extern class PassThrough extends TransformStream<Buffer, Buffer> {}
