package tannus.ds;

//import tannus.ds.Maybe;

import tannus.ds.Dict;
import tannus.nore.ORegEx;
import tannus.nore.Selector;

import Reflect.*;

import haxe.macro.Expr;

using haxe.macro.ExprTools;
using tannus.macro.MacroTools;

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
}
