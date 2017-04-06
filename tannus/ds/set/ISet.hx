package tannus.ds.set;

import tannus.io.*;

import tannus.ds.set.*;

using Lambda;
using tannus.ds.ArrayTools;

interface ISet<T> {
    var length(get, never):Int;

    function add(v : T):Bool;
    function empty():Set<T>;
    function copy():Set<T>;
    function pushMany(i : Iterable<T>):Void;
    function reduce<TOut>(handler:TOut->T->TOut, acc:TOut):TOut;
    function difference(o : Set<T>):Set<T>;
    function union(o : Set<T>):Set<T>;
    function intersection(o : Set<T>):Set<T>;
    function filter(f : T->Bool):Set<T>;
    function map<TOut>(f : T->TOut):Array<TOut>;
    function iterator():Iterator<T>;
    function push(v : T):Void;
    function exists(v : T):Bool;
    function remove(v : T):Bool;
    function toArray():Array<T>;
    function toString():String;
}
