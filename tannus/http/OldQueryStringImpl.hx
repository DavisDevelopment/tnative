package tannus.http;

import tannus.io.*;
import tannus.ds.*;

import tannus.sys.Path;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;
using tannus.FunctionTools;
using tannus.ds.MapTools;
using tannus.ds.IteratorTools;

@:expose('QueryString')
class QueryStringImpl {
    /* Constructor Function */
    public function new(?d: Dict<String, QueryStringValue>) {
        if (d != null) {
            this.data = d;
        }
        else {
            this.data = new Dict();
        }
    }

/* === Instance Methods === */

    public inline function get(name: String):Null<QueryStringValue> {
        return data[name];
    }

    public function set(name:String, value:String):QueryString {
        data[name] = [value];
        return cast this;
    }

    public inline function remove(name: String):Bool return data.remove( name );
    public inline function removeValue(name:String, value:String):Bool {
        if (!data.exists( name )) {
            return false;
        }
        else {
            return get( name ).remove( value );
        }
    }

    public function add(name:String, value:String):QueryString {
        var arr:Array<String> = get( name );
        if (null == arr) {
            arr = value == null ? [] : [value];
            data.set(name, arr);
        }
        else if (null != value) {
            arr.push( value );
        }
        return cast this;
    }

    public function clone():QueryString {
        var cd:Dict<String, QueryStringValue> = new Dict();
        for (name in data.keys()) {
            cd[name] = data[name].copy();
        }
        return cast new QueryStringImpl( cd );
    }

    public inline function setMany(name:String, values:Array<String>):QueryString {
        data[name] = values;
        return cast this;
    }

    public function keys():Iterator<String> return data.keys();
    public inline function exists(name: String):Bool return data.exists( name );

    public function toStringWithSymbols(separator:String, assignment:String, ?encodeURIComponent:String->String):String {
        if (data == null) {
            return null;
        }
        if (encodeURIComponent == null) {
            encodeURIComponent = QueryStringImpl.encodeURIComponent;
        }
        return keys().map(function(k: String) {
            var vs = get( k );
            var ek = encodeURIComponent( k );
            if (vs.length == 0) {
                return [ek];
            }
            else {
                return vs.map(x -> '$ek$assignment${encodeURIComponent(x)}');
            }
        }).array().flatten().join( separator );
    }

    public function toString():String {
        return toStringWithSymbols(separator, assignment);
    }

    public static function encodeURIComponent(s: String):String return s.urlEncode().replace("%20", "+");
    public static function decodeURIComponent(s: String):String return s.urlDecode().replace("+", " ");

    public static function parseWithSymbols(s:String, separator:String, assignment:String, ?decodeURIComponent:String->String):QueryString {
        if (s.empty()) {
            return cast new QueryStringImpl();
        }
        else {
            if (decodeURIComponent == null) {
                decodeURIComponent = QueryStringImpl.decodeURIComponent;
            }
            if (s.startsWith('?') || s.startsWith('#')) {
                s = s.slice( 1 );
            }
            s = s.ltrim();
            return cast s.split( separator ).reduce(function(qs:QueryStringImpl, v:String) {
                var parts = v.split( assignment );
                if (!parts[0].empty()) {
                    qs.add(decodeURIComponent(parts[0]), (parts[1].empty() ? null : decodeURIComponent(parts[1])));
                }
                return qs;
            }, new QueryStringImpl());
        }
    }

    public static inline function parse(s: String):QueryString {
        return parseWithSymbols(s, separator, assignment, decodeURIComponent);
    }

    public static function fromObject(o: {}):QueryStringImpl {
        var qs:QueryStringImpl = new QueryStringImpl();
        if (!Reflect.isObject( o )) {
            throw 'unable to convert $o to a QueryString';
        }
        var o:Object = new Object( o );
        for (key in o.keys) {
            var val = o[key];
            if ((val is Array<String>)) {
                qs.setMany(key, (val : Array<Dynamic>).map(x -> '$x'));
            }
            else {
                qs.set(key, '$val');
            }
        }
        return cast qs;
    }

    public function toObject():{} {
        var o:Object = new Object({});
        return keys().array().reduce(function(o: Object, key: String) {
            var v = get( key );
            if (v.empty()) {
                o[key] = null;
            }
            else if (v.length == 1) {
                o[key] = v[1];
            }
            else {
                o[key] = v;
            }
            return o;
        }, o);
    }

/* === Instance Fields === */

    public static var assignment:String = '=';
    public static var separator:String = '&';

    private var data:Dict<String, QueryStringValue>;
}


@:forward
abstract QueryStringValue (Array<String>) from Array<String> to Array<String> {
    @:to
    public inline function toString():Null<String> {
        if (this.empty()) {
            return null;
        }
        else {
            return this.join(',');
        }
    }
}
