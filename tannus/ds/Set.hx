package tannus.ds;

import tannus.io.*;

import tannus.ds.set.*;

using Lambda;
using tannus.ds.ArrayTools;

@:multiType
@:forward
abstract Set<T> (ISet<T>) {
    public function new():Void;

/* === Overloads === */

    public function iterator():Iterator<T> return this.iterator();
    public inline function empty():Set<T> return this.empty();
    public inline function copy():Set<T> return this.copy();

    @:op(A - B)
    public inline function difference(o : Set<T>):Set<T> return this.difference( o );
    @:op(A + B)
    public inline function union(o : Set<T>):Set<T> return this.union( o );
    public inline function intersection(o : Set<T>):Set<T> return this.intersection( o );
    public inline function filter(f : T->Bool):Set<T> return this.filter( f );

/* === Casting === */

    @:to
    public static inline function toStringSet<T:String>(s : ISet<T>):StringSet {
        return new StringSet();
    }

    @:to
    public static inline function toIntSet<T:Int>(s : ISet<T>):IntSet {
        return new IntSet();
    }
    
    @:to
    public static inline function toEnumValueSet<T:EnumValue>(s : ISet<T>):EnumValueSet<T> {
        return new EnumValueSet();
    }

    @:to
    public static inline function toIComparableSet<T:IComparable<T>>(s : ISet<T>):IComparableSet<T> {
        return new IComparableSet();
    }
}
