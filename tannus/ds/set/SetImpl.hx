package tannus.ds.set;

import tannus.ds.*;
import tannus.io.*;

using Lambda;
using tannus.ds.ArrayTools;

class SetImpl<T> implements ISet<T> {
    /* Constructor Function */
    public function new(d : Dict<T, Bool>):Void {
        this.d = d;
    }

/* === Instance Methods === */

    public function add(v : T):Bool {
        return if (exists( v ))
            false;
        else {
            push( v );
            true;
        }
    }

    public function empty():Set<T> {
        return untyped Type.createInstance(Type.getClass( this ), []);
    }

    public function copy():Set<T> {
        var s = empty();
        for (v in this)
            s.push( v );
        return s;
    }

    public function pushMany(values : Iterable<T>):Void {
        for (v in values)
            push( v );
    }

    public function reduce<TOut>(handler:TOut->T->TOut, acc:TOut):TOut {
        for (v in iterator()) {
            acc = handler(acc, v);
        }
        return acc;
    }

    public function difference(set : Set<T>):Set<T> {
        var result = copy();
        for (item in set) {
            result.remove( item );
        }
        return result;
    }

    public function filter(predicate : T -> Bool):Set<T> {
        return reduce(function(acc:Set<T>, v:T) {
            if (predicate( v )) {
                acc.add( v );
            }
            return acc;
        }, empty());
    }

    public function map<TOut>(f : T -> TOut):Array<TOut> {
        return reduce(function(acc:Array<TOut>, v:T) {
            acc.push(f( v ));
            return acc;
        }, []);
    }

    public inline function intersection(set : Set<T>):Set<T> {
        var result = empty();
        for (item in iterator()) {
            if (set.exists( item )) {
                result.push( item );
            }
        }
        return result;
    }

    public function iterator():Iterator<T> return d.keys();

    public inline function push(v : T):Void d.set(v, true);
    public inline function exists(v : T):Bool return d.exists( v );
    public inline function remove(v : T):Bool return d.remove( v );

    public function union(set : Set<T>):Set<T> {
        var s = copy();
        s.pushMany(untyped set);
        return s;
    }

    public function toArray():Array<T> {
        var a:Array<T> = new Array();
        for (v in this)
            a.push( v );
        return a;
    }

    public function toString():String {
        return ('{' + (toArray().join(', ')) + '}');
    }

/* === Computed Instance Fields === */

    public var length(get, never):Int;
    private function get_length():Int {
        var l = 0;
        for (i in this)
            ++l;
        return l;
    }

/* === Instance Fields === */

    private var d : Dict<T, Bool>;
}
