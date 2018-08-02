package tannus.io;

import tannus.io.*;
import tannus.io.Chunk;
import tannus.ds.*;
import tannus.async.*;
import tannus.stream.Stream;
import tannus.stream.StreamObject;

import haxe.io.Bytes;
import haxe.ds.Option;
import haxe.ds.Either;
import haxe.extern.EitherType;
import haxe.Constraints.Function;

import tannus.io.chunk.*;

using Slambda;
using tannus.ds.ArrayTools;
using tannus.FunctionTools;
using tannus.async.OptionTools;
using tannus.async.Asyncs;

@:forward(reduce)
abstract Source<E> (SourceObject<E>) from SourceObject<E> to SourceObject<E> {

}

typedef SourceObject<E> = StreamObject<Chunk, E>;
typedef RealSource = Source<Dynamic>;

