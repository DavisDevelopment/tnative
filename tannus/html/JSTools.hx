package tannus.html;

import tannus.ds.Obj;
import tannus.io.*;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.Constraints;
import haxe.extern.EitherType;

import js.Symbol;

using haxe.macro.ExprTools;
using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;
using Reflect;

class JSTools {
    public static inline function jsiterator<T>(o : Dynamic):Iterator<T> {
        return new JsIterator(o, null);
    }
	/**
	  * Convert the given object into an Array
	  */
	public static inline function arrayify<T>(o : Dynamic):Array<T> {
		return cast (untyped __js__('Array.prototype.slice.call')(o, 0));
	}

	public static inline function callprop<T>(o:Dynamic, name:String, ?args:Array<Dynamic>):T {
	    return JSFunctionTools.apply(nativeArrayGet(o, name), o, args);
	}

	public static function fthis<T:Function>(with_self: Function):T {
	    untyped {
	        return Reflect.makeVarArgs(function(args: Array<Dynamic>) {
	            var self:Dynamic = __js__('this');
	            trace( self );
	            args.unshift( self );
	            return Reflect.callMethod(null, with_self, args);
	        });
	    };
	}

	public static inline function nativeArrayGet<T>(o:Dynamic, index:OIndex):T {
	    return untyped o[untyped index];
	}
	public static inline function nag<T>(o:Dynamic, i:OIndex):T return nativeArrayGet(o, i);

	public static inline function nativeArraySet<T>(o:Dynamic, index:OIndex, value:T):T {
	    return (untyped o[untyped index] = value);
	}
	public static inline function nas<T>(o:Dynamic, i:OIndex, v:T):T return nativeArraySet(o, i, v);

	public static inline function nativeArrayDelete(o:Dynamic, index:OIndex):Void {
	   (untyped __js__('delete'))(nativeArrayGet(o, index));
	}
	public static inline function nad(o:Dynamic, i:OIndex):Void return nativeArrayDelete(o, i);

	public static inline function defineGetter(o:Dynamic, name:String, value:Getter<Dynamic>):Void {
		//o.getProperty('__defineGetter__').call(o, name, value);
		nativeArrayGet(o, '__defineGetter__').call(o, name, value);
	}

	public static inline function defineSetter(o:Dynamic, name:String, value:Setter<Dynamic>):Void {
		//o.getProperty('__defineSetter__').call(o, name, value);
		nativeArrayGet(o, '__defineSetter__').call(o, name, value);
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

class JSFunctionTools {
    public static inline function apply<T:Function,TRet>(f:T, ctx:Dynamic, ?args:Array<Dynamic>):TRet {
        return (untyped f).apply(ctx, (args!=null?args:[]));
    }

    public static inline function construct<TFunc:Function, TInst>(f:TFunc, ?parameters:Array<Dynamic>):TInst {
        return Type.createInstance((untyped f), (parameters != null ? parameters : []));
    }

	public static function fthis<T:Function>(with_self: Function):T {
	    untyped {
	        return Reflect.makeVarArgs(function(args: Array<Dynamic>) {
	            var self:Dynamic = __js__('this');
	            trace( self );
	            args.unshift( self );
	            return Reflect.callMethod(null, with_self, args);
	        });
	    };
	}
}

typedef NativeJsIterator<T> = {
    next: Void->{value:Null<T>, done:Bool}
};

class JsIterator<T> {
    private var i:NativeJsIterator<T>;
    private var x:Null<{value:Null<T>,done:Bool}>;

    public function new(?o:Dynamic, ?i:NativeJsIterator<T>):Void {
        x = null;
        switch ([o, i]) {
            case [null, null]:
                throw 'Error: Both constructor arguments to tannus.html.JSTools.JsIterator cannot be null';

            case [_, i] if (i != null):
                this.i = i;

            case [o, null]:
                var iterf:Null<Void->NativeJsIterator<T>> = JSTools.nag(o, (untyped Symbol).iterator);
                if (untyped __strict_neq__(js.Lib.typeof( iterf ), 'undefined')) {
                    if (Reflect.isFunction( iterf )) {
                        this.i = JSFunctionTools.apply(iterf, o);
                    }
                    else {
                        throw 'TypeError: Invalid Iterator property';
                    }
                }
                else {
                    throw 'TypeError: Invalid Iterable object';
                }
        }
    }

    public function hasNext():Bool {
        if (x == null) {
            return false;
        }
        else {
            return !x.done;
        }
    }

    public function next():T {
        x = i.next();
        return x.value;
    }
}

typedef JsPropDescriptor = {
    ?configurable: Bool,
    ?enumerable: Bool,
    ?value: Dynamic,
    ?writable: Bool,
    ?get: Void->Dynamic,
    ?set: Dynamic->Dynamic
};

typedef OIndex = EitherType<EitherType<String,Int>, js.Symbol>;
