package tannus.encoding;

import tannus.ds.*;

import tannus.encoding.StructuredCloneCompatible;

import Std.*;
import tannus.math.TMath.*;

import js.RegExp;
import js.html.*;

using Slambda;
using tannus.ds.ArrayTools;
using StringTools;
using tannus.ds.StringUtils;

class StructuredCloneTools {
/* === Static Methods === */

    /**
      * check if [o] is an ClassNode
      */
    public static inline function isClassNode(o : Object):Bool {
        return (
            (o.exists( CLASSKEY )) &&
            (o.exists('data'))
        );
    }
    public static inline function asClassNode(o : Object):StructuredCloneClassNode {
        return {type:o[CLASSKEY], data:o['data']};
    }

    /**
      * check if [o] is an EnumNode
      */
    public static inline function isEnumNode(o : Object):Bool {
        return (
            (o.exists( ENUMKEY )) &&
            (o.exists('data')) &&
            (o.exists('name') || o.exists('index'))
        );
    }
    public static inline function asEnumNode(o : Object):StructuredCloneEnumNode {
        return {
            type: o[ENUMKEY],
            name: o['name'],
            index: o['index'],
            data: o['data']
        }
    }

    public static inline function isCacheNode(o : Object):Bool {
        return (o.exists( CACHEKEY ));
    }
    public static inline function asCacheNode(o : Object):StructuredCloneCacheNode {
        return {
            index: o[CACHEKEY]
        };
    }

    /**
      * check if [o] is 'structured clone compatible'
      */
    public static function isStructureCloneCompatible(o : Dynamic):Bool {
        return (
            is(o, Bool) || is(o, Float) || is(o, Int) || is(o, String) ||
            is(o, Date) || is(o, RegExp) || is(o, EReg) ||
            is(o, Blob) || is(o, File) || is(o, FileList) ||
            is(o, ArrayBuffer) || is(o, DataView) ||
            is(o, Int8Array) || is(o, Uint8Array) || is(o, Uint8ClampedArray) ||
            is(o, Int16Array) || is(o, Uint16Array) ||
            is(o, Int32Array) || is(o, Uint32Array) ||
            is(o, Float32Array) || is(o, Float64Array) ||
            is(o, ImageData)
        );
    }

    public static function isJsonCompatible(x : Dynamic):Bool {
        return (
            is(x, Bool) || is(x, Float) || is(x, String)
        );
    }

    public static function isJsonIncompatible(x : Dynamic):Bool {
        return (
            is(x, Date) || is(x, EReg) || is(x, RegExp) ||
            is(x, Blob) || is(x, File) || is(x, FileList) ||
            is(x, ArrayBuffer) || is(x, DataView) ||
            is(x, Int8Array) || is(x, Uint8Array) || is(x, Uint8ClampedArray) ||
            is(x, Int16Array) || is(x, Uint16Array) ||
            is(x, Int32Array) || is(x, Uint32Array) ||
            is(x, Float32Array) || is(x, Float64Array) ||
            is(x, ImageData)
        );
    }

    /**
      * determine whether [x] is a Typed Array
      */
    public static function isTypedArray(x : Dynamic):Bool {
        return (
            is(x, ArrayBuffer) || is(x, DataView) ||
            is(x, Int8Array) || is(x, Uint8Array) || is(x, Uint8ClampedArray) ||
            is(x, Int16Array) || is(x, Uint16Array) ||
            is(x, Int32Array) || is(x, Uint32Array) ||
            is(x, Float32Array) || is(x, Float64Array)
        );
    }

/* === Static Fields === */

    public static inline var CLASSKEY:String = '&class';
    public static inline var ENUMKEY:String = '&enum';
    public static inline var CACHEKEY:String = '&cache';
    public static inline var ENCODEMETHODKEY:String = 'hxscGetData';
    public static inline var DECODEMETHODKEY:String = 'hxscSetData';
}

@:structInit
class StructuredCloneClassNode {
    @:native('&class')
    public var type : String;
    public var data : Dynamic;
}

@:structInit
class StructuredCloneEnumNode {
    @:native('&enum')
    public var type : String;
    @:optional public var name : String;
    @:optional public var index : Int;
    public var data : Array<Dynamic>;
}

@:structInit
class StructuredCloneCacheNode {
    @:native('&cache')
    public var index : Int;
}
