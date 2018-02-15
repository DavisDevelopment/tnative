package tannus.node;

import tannus.async.*;
import haxe.extern.EitherType;

import tannus.node.Buffer;
import tannus.node.EventEmitter;
import tannus.node.WritableStream;
import haxe.Constraints.Function;

typedef Duplex = tannus.node.DuplexStream.SymmetricalDuplexStream<Dynamic>;
