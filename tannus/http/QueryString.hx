package tannus.http;

import tannus.io.*;
import tannus.ds.*;

import tannus.sys.Path;

import tannus.http.QueryStringImpl;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;
using tannus.FunctionTools;

@:forward
abstract QueryString (QueryStringImpl) from QueryStringImpl to QueryStringImpl {
    public inline function new(?d: Dict<String, QueryStringValue>) {
        this = new QueryStringImpl( d );
    }

    @:arrayAccess
    public inline function get(s:String):Null<QueryStringValue> return this.get( s );

    @:arrayAccess
    public inline function set(s:String, v:String):QueryString return this.set(s, v);

    @:to
    public inline function toString():String return this.toString();

    @:from
    public static inline function parse(v:String):QueryString return QueryStringImpl.parse( v );

    @:to
    public inline function toObject():{} return this.toObject();

    @:from
    public static inline function fromImpl(i: QueryStringImpl):QueryString return untyped i;
    
    @:from
    public static inline function fromObject(o: {}):QueryString return fromImpl(QueryStringImpl.fromObject( o ));
}
