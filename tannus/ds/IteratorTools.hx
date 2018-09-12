package tannus.ds;

import tannus.io.*;

import haxe.ds.Option;

using tannus.FunctionTools;
using tannus.async.OptionTools;

class IteratorTools {
	/**
	  * 'map' an Iterator, like one would an Array
	  */
	public static inline function map<A, B>(iterator:Iterator<A>, mapper:A->B):Iterator<B> {
		return new MappedIterator(iterator, mapper);
	}

	public static inline function join<T>(i:Iterator<T>, o:Iterator<T>):Iterator<T> {
	    return Itr.compound([i, o]);
	}

	public static inline function flatten<T>(i: Itr<Iterator<T>>):Itr<T> {
	    return Itr.compound(array(i));
	}

	/**
	  * reduce an Iterator
	  */
	public static inline function reduce<T, TAcc>(iterator:Iterator<T>, f:TAcc->T->TAcc, acc:TAcc):TAcc {
	    while (iterator.hasNext()) {
	        acc = f(acc, iterator.next());
	    }
	    return acc;
	}

	/**
	  * read an Iterator into an Array
	  */
	public static function array<T>(iterator: Iterator<T>):Array<T> {
	    var a = [];
	    for (x in iterator)
	        a.push( x );
	    return (a:Array<T>);
	}
}

private class MappedIterator<A, B> {
	public inline function new(iterator:Iterator<A>, mapper:A->B):Void {
		i = iterator;
		f = mapper;
	}

	public inline function hasNext():Bool return i.hasNext();
	public inline function next():B return f(i.next());

	private var i:Iterator<A>;
	private var f:A -> B;
}

private class EmptyIter<T> {
    public function new() { }
    public function hasNext():Bool return false;
    public function next():T throw 0;

    static var inst = new EmptyIter();

    @:noUsing
    public static function make<T>():EmptyIter<T> {
        return (cast inst : EmptyIter<T>);
    }
}

private class SingleIter<T> {
    public inline function new(v: T) {
        this.v = Some(v);
    }

    public inline function hasNext():Bool {
        return v.isSome();
    }

    public function next():T {
        return switch v {
            case Some(ret):
                v = None;
                ret;

            case None:
                #if debug
                throw 'iterator has ended. next() should not be called';
                #else
                return null;
                #end
        }
    }

    var v(default, null): Option<T>;
}

class CompoundIter<T> {
    /* Constructor Function */
    public function new(a:Itr<T>, b:Itr<T>) {
        this.a = a;
        this.b = b;
    }

/* === Methods === */

    public inline function hasNext():Bool {
        return (a != null && a.hasNext()) || (b != null && b.hasNext());
    }

    public function next():T {
        var ret: T;
        if (a != null && a.hasNext()) {
            ret = a.next();
            if (!a.hasNext())
                a = null;
        }
        else if (b != null && b.hasNext()) {
            ret = b.next();
            if (!b.hasNext())
                b = null;
        }
        else {
            a = null;
            b = null;
            ret = null;
        }
        return ret;
    }

    @:noUsing
    public static function build<T>(iters: Array<Itr<T>>):Itr<T> {
        if (iters.length == 0)
            return EmptyIter.make();

        //var i = 0, cur = iters[i];
        //while (i < iters.length && iters[i + 1] != null) {
            //cur = new CompoundIter(cur, iters[++i]);
        //}
        var cur = iters.shift(), tmp;
        while (iters.length > 0) {
            tmp = iters.shift();
            cur = new CompoundIter(cur, tmp != null ? tmp : EmptyIter.make());
        }
        return cur;
    }

/* === Variables === */

    var a(default, null): Null<Itr<T>>;
    var b(default, null): Null<Itr<T>>;
}

@:forward
abstract Itr<T> (Iterator<T>) from Iterator<T> to Iterator<T> {
    @:noUsing
    public static function single<T>(v: T):Itr<T> {
        return new SingleIter( v );
    }

    @:noUsing
    public static function empty<T>():Itr<T> {
        return (EmptyIter.make() : Itr<T>);
    }

    @:from
    @:noUsing
    public static function compound<T>(ia: Array<Itr<T>>):Itr<T> {
        return CompoundIter.build( ia );
    }
}

class FwdItr<T> {
    public function new(i: Itr<T>) {
        this.i = i;
    }
    public function hasNext():Bool return i.hasNext();
    public function next():T return i.next();
    var i(default, null): Itr<T>;
}

class RefItr<T> {
    public function new(i: Ref<Itr<T>>) {
        this.i = i;
    }

    public function hasNext():Bool {
        return i.get().hasNext();
    }

    public function next():T {
        return i.get().next();
    }

    var i(default, null): Ref<Itr<T>>;
}

