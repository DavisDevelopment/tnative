package tannus.html;

import tannus.ds.Obj;
import tannus.io.*;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.Constraints;

using haxe.macro.ExprTools;
using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;
using Reflect;

class JSTools {
	/**
	  * Convert the given object into an Array
	  */
	public static inline function arrayify<T>(o : Dynamic):Array<T> {
		return cast (untyped __js__('Array.prototype.slice.call')(o, 0));
	}

	public static inline function defineGetter(o:Dynamic, name:String, value:Getter<Dynamic>):Void {
		o.getProperty('__defineGetter__').call(o, name, value);
	}
	public static inline function defineSetter(o:Dynamic, name:String, value:Setter<Dynamic>):Void {
		o.getProperty('__defineSetter__').call(o, name, value);
	}
	public static inline function definePointer(o:Dynamic, name:String, value:Ptr<Dynamic>):Void {
		defineGetter(o, name, value.getter);
		defineSetter(o, name, value.setter);
	}
	public static inline function defineProperty(o:Dynamic, name:String, descriptor:JsPropDescriptor):Void {
	    (untyped __js__('Object.defineProperty'))(o, name, descriptor);
	}
	public static inline function defineProperties(o:Dynamic, descriptors:Dynamic<JsPropDescriptor>):Void {
	    (untyped __js__('Object.defineProperties'))(o, descriptors);
	}

/* === Private Shit === */
}

typedef JsPropDescriptor = {
    ?configurable: Bool,
    ?enumerable: Bool,
    ?value: Dynamic,
    ?writable: Bool,
    ?get: Void->Dynamic,
    ?set: Dynamic->Dynamic
};
