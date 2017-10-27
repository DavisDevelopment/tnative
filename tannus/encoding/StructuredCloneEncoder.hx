package tannus.encoding;

import tannus.ds.*;

import tannus.encoding.StructuredCloneCompatible;

import Std.*;
import tannus.math.TMath.*;
import tannus.encoding.StructuredCloneTools.*;

import js.html.*;

using Slambda;
using tannus.ds.ArrayTools;
using StringTools;
using tannus.ds.StringUtils;
using tannus.encoding.StructuredCloneTools;

class StructuredCloneEncoder {
    /* Constructor Function */
    public function new():Void {
        this.enumIndex = ENUM_INDEX;
        this.useCache = USE_CACHE;
        this.jsonOnly = JSON_ONLY;
    }

/* === Instance Methods === */

    /**
      * encode a value
      */
    public function encode(v : Dynamic):Dynamic {
        if (v == null || v.isStructureCloneCompatible()) {
            return v;
        }
        else {
            return encodeValue( v );
        }
    }

    /**
      * encode a value
      */
    private function encodeValue(v : Object):Dynamic {
        // default behavior
        if (v == null) {
            return null;
        }
        else if (v.isStructureCloneCompatible()) {
            if ( jsonOnly ) {
                return encodeJsonOnlyValue( v );
            }
            else {
                return v;
            }
        }
        else if ((v is Array<Dynamic>)) {
            var va:Array<Dynamic> = cast v;
            var key = cacheKeyFor( va );
            if (key == null) {
                var copy:Array<Dynamic> = va.map( encodeValue );
                cacheValue(va, copy);
                return copy;
            }
            else {
                return cacheNode( key );
            }
        }
        else if (Reflect.isEnumValue( v )) {
            var key = cacheKeyFor( v );
            if (key == null) {
                var node = enumNode( v );
                cacheValue(v, node);
                return node;
            }
            else {
                return cacheNode( key );
            }
        }
        else {
            var key = cacheKeyFor( v );
            if (key == null) {
                var type:Null<Class<Dynamic>> = Type.getClass( v );
                if (type != null) {
                    var node = classNode( v );
                    cacheValue(v, node);
                    return node;
                }
                else {
                    var copy:Object = {};
                    for (key in v.keys) {
                        copy[key] = encodeValue(v[key]);
                    }
                    cacheValue(v, copy);
                    return copy;
                }
            }
            else {
                return cacheNode( key );
            }
        }
    }

    /**
      * encode a 'json-only' value
      */
    private function encodeJsonOnlyValue(x : Dynamic):Dynamic {
        if (x.isJsonIncompatible()) {
            //TODO
            return null;
        }
        else if (x.isJsonCompatible()) {
            return x;
        }
        else if ((x is Array<Dynamic>)) {
            return cast(x, Array<Dynamic>).map( encodeJsonOnlyValue );
        }
        else {
            return encodeValue( x );
        }
    }

    /**
      * create and return a CacheNode
      */
    private function cacheNode(key : Int):StructuredCloneCacheNode {
        return {
            index: key
        };
    }

    /**
      * create and return a ClassNode
      */
    private function classNode(o : Object):StructuredCloneClassNode {
        var node:StructuredCloneClassNode = {
            type: Type.getClassName(Type.getClass( o )),
            data: null
        };
        if (o[ENCODEMETHODKEY] == null) {
            node.data = encodeValue(Reflect.copy( o ));
        }
        else {
            node.data = encodeValue(o.call( ENCODEMETHODKEY ));
        }
        return node;
    }

    /**
      * create and return an EnumNode
      */
    private function enumNode(o : Dynamic):StructuredCloneEnumNode {
        var node:StructuredCloneEnumNode = {
            type: Type.getEnumName(Type.getEnum( o )),
            name: Type.enumConstructor( o ),
            data: encodeValue(Type.enumParameters( o ))
        };
        return node;
    }

    /**
      * cache the given value
      */
    private function cacheValue(value:Dynamic, encoded:Dynamic):Void {
        initCache();
        cache[nextCacheKey++] = {value:value, encoded:encoded};
    }

    private function isCached(v : Dynamic):Bool {
        initCache();
        return (cacheKeyFor( v ) != null);
    }

    /**
      * get the 'cache key' for [x]
      */
    private function cacheKeyFor(x : Dynamic):Null<Int> {
        initCache();
        for (i in cache.keys()) {
            var y = cache[i].value;
            if (x == y || ((Reflect.isEnumValue(x) && Reflect.isEnumValue(y)) && Type.enumEq(x, y))) {
                return i;
            }
        }
        return null;
    }

    /**
      * ensure that the [cache] system is initialized
      */
    private inline function initCache():Void {
        if (cache == null) {
            cache = new Dict();
        }
        if (nextCacheKey == null) {
            nextCacheKey = 0;
        }
    }

/* === Instance Fields === */

    public var enumIndex : Bool;
    public var useCache : Bool;
    public var jsonOnly : Bool;

    private var cache : Dict<Int, {value:Dynamic, encoded:Dynamic}>;
    private var nextCacheKey : Int;

/* === Static Methods === */

    public static function run(v : Dynamic):Dynamic {
        return (new StructuredCloneEncoder().encode( v ));
    }

    public static var ENUM_INDEX:Bool = false;
    public static var USE_CACHE:Bool = true;
    public static var JSON_ONLY:Bool = false;
}
