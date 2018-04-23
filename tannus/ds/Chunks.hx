package tannus.ds;

import tannus.ds.*;
import tannus.io.*;

import Slambda.fn;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;

class Chunks<T> {
    /* Constructor Function */
    public function new(maxSize:Int=10, ?values:Iterable<T>) {
        c = new Array();
        l = [maxSize];

        if (values != null) {
            pushMany( values );
        }
    }

/* === Instance Methods === */

    /**
      * check whether [this] Chunks<T> instance is empty
      */
    public function empty():Bool {
        return (c.empty() || c.all.fn(_.empty()));
    }

    public inline function hasContent():Bool {
        return !empty();
    }

    public function push(value: T):Chunks<T> {
        return foo( value );
    }

    public function pushMany(values: Iterable<T>):Chunks<T> {
        return fooMany(values);
    }

    public function pushChunk(chunk: Array<T>):Chunks<T> {
        if (chunk.length == maxLength) {
            if (c.empty() || c.last().length == maxLength) {
                c.push( chunk );
                return this;
            }
            //
        }
        return pushMany( chunk );
    }

    public function unshift(value: T):Chunks<T> {
        return foo(value, fn(_1.unshift(_2)), fn(_[0]));
    }

    public function unshiftMany(values: Iterable<T>):Chunks<T> {
        return fooMany(values, fn(_1.unshift(_2)), fn(_[0]));
    }

    public function unshiftChunk(chunk: Array<T>):Chunks<T> {
        if (chunk.length == maxLength && (c.empty() || c.last().length == maxLength)) {
            c.unshift( chunk );
            return this;
        }
        else {
            return unshiftMany( chunk );
        }
    }

    @:noCompletion
    public function rebase(c:Array2<T>, l:Array<Int>):Chunks<T> {
        this.c = c;
        this.l = l;
        return this;
    }

    public function reset():Chunks<T> {
        return rebase([], [maxLength]);
    }

    public function reflow():Chunks<T> {
        var tmp = this.c;
        reset();
        for (chunk in tmp) {
            if (chunk.length == maxLength) {
                pushChunk( chunk );
            }
            else {
                pushMany( chunk );
            }
        }
        return this;
    }

    public function iterator():Iterator<Array<T>> {
        return c.iterator();
    }

    public function pop():Null<Array<T>> {
        return focp();
    }

    public function popValue():Null<T> {
        return fop();
    }

    public function shift():Null<Array<T>> {
        return focp(fn(_.shift()));
    }

    public function shiftValue():Null<T> {
        return fop(fn(_[0]), fn(_.shift()), fn(_.shift()));
    }

    private function focp(?a:Array2<T>->Array<T>):Null<Array<T>> {
        if (a == null) {
            a = fn(_.pop());
        }

        var chunk:Array<T> = a( this.c );
        if (chunk == null) {
            return null;
        }
        else {
            return chunk;
        }
    }

    private function fop(?a:Array2<T>->Array<T>, ?b:Array2<T>->Array<T>, ?c:Array<T>->T):Null<T> {
        // == Prepare Values == //
        if (a == null) {
            a = fn(_.last());
        }
        if (b == null) {
            b = fn(_.pop());
        }
        if (c == null) {
            c = fn(_.pop());
        }

        var chunk:Array<T> = a( this.c );
        if (chunk == null) {
            return null;
        }
        else if (chunk.empty()) {
            b( this.c );
            return fop(a, b, c);
        }
        else {
            return c( chunk );
        }
    }

    private function fooMany(values:Iterable<T>, ?a:Array2<T>->Array<T>->Void, ?b:Array2<T>->Array<T>, ?c:Array<T>->T->Void):Chunks<T> {
        // == Prepare Values == //
        if (a == null) {
            a = ((chunks, chunk) -> chunks.push( chunk ));
        }
        if (b == null) {
            b = fn(_.last());
        }
        if (c == null) {
            c = ((chunk, value) -> chunk.push( value ));
        }

        for (x in values) {
            foo(x, a, b, c);
        }
        return this;
    }

    private function foo(value:T, ?a:Array2<T>->Array<T>->Void, ?b:Array2<T>->Array<T>, ?c:Array<T>->T->Void):Chunks<T> {
        // == Prepare Values == //
        if (a == null) {
            a = ((chunks, chunk) -> chunks.push( chunk ));
        }
        if (b == null) {
            b = fn(_.last());
        }
        if (c == null) {
            c = ((chunk, value) -> chunk.push( value ));
        }

        var chunk:Array<T> = b( this.c );
        if (chunk == null || chunk.length >= maxLength) {
            a(this.c, chunk = new Array());
        }
        c(chunk, value);
        return this;
    }

/* === Computed Instance Fields === */

    public var maxLength(get, set):Int;
    private inline function get_maxLength() return l[0];
    private inline function set_maxLength(v) return (l[0] = v);

/* === Instance Fields === */

    private var c:Array2<T>;
    private var l:Array<Int>;
}

private typedef Array2<T> = Array<Array<T>>;
