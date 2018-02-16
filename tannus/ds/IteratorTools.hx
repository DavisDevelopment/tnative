package tannus.ds;

import tannus.io.*;

class IteratorTools {
	/**
	  * 'map' an Iterator, like one would an Array
	  */
	public static inline function map<A, B>(iterator:Iterator<A>, mapper:A->B):Iterator<B> {
		return new FunctionalIterator(iterator, mapper);
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

private class FunctionalIterator<A, B> {
	public inline function new(iterator:Iterator<A>, mapper:A->B):Void {
		i = iterator;
		f = mapper;
	}

	public inline function hasNext():Bool return i.hasNext();
	public inline function next():B return f(i.next());

	private var i:Iterator<A>;
	private var f:A -> B;
}
