package tannus.ds;

//import tannus.ds.Maybe;

import tannus.ds.Dict;
import tannus.nore.ORegEx;
import tannus.nore.Selector;

import Reflect.*;

import haxe.macro.Expr;

using haxe.macro.ExprTools;
using tannus.macro.MacroTools;

using Slambda;
using tannus.ds.ArrayTools;
using tannus.ds.AnonTools;
using tannus.FunctionTools;
using tannus.ds.IteratorTools;
#if js
using tannus.html.JSTools;
#end

abstract Anon<T> (Dynamic<T>) from Dynamic<T> to Dynamic<T> {
    public inline function new() this = {};
    @:arrayAccess
    public inline function get(key: String):Null<T> return #if js untyped this[key]; #else field(this, key); #end
    @:arrayAccess
    public inline function set(key:String, value:T):T {
        #if js
        return untyped this[key] = value;
        #else
        setField(this, key, value);
        return value;
        #end
    }
    public inline function exists(key: String):Bool return hasField(this, key);
    public inline function remove(key: String):Bool return deleteField(this, key);
    public inline function keys():Array<String> return fields( this );
    public function iterator():Iterator<T> return keys().iterator().map(k->get(k));

    @:op(A << B)
    public function assign<T>(right: Anon<T>):Anon<T> {
        #if js
        return untyped __js__('Object.assign({0}, {1})', this, right);
        #else
        for (key in right.keys())
            set(key, right[key]);
        return this;
        #end
    }

    @:from
    public static inline function of<T>(betty: Dynamic<T>):Anon<T> {
        return cast betty;
    }
}
