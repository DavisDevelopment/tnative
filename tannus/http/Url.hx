package tannus.http;

import haxe.ds.Option;
import haxe.extern.EitherType as Either;
import haxe.Constraints.IMap;

//import thx.Error;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;
using tannus.async.OptionTools;
using tannus.FunctionTools;

/**
  abstract type to represent a Url
 **/
abstract Url (UrlType) from UrlType to UrlType {
    /* Constructor Function */
    public inline function new(href:String, parseQueryString:Bool=true):Void {
        this = cast parse(href, parseQueryString);
    }

    /**
      the EReg pattern used to parse Urls
     **/
    public static var pattern(default, null):EReg = ~/^((((?:([^:\/#\?]+):)?(?:(\/\/)?((?:(([^:@\/#\?]+)(?:[:]([^:@\/#\?]+))?)@)?(([^:\/#\?\]\[]+|\[[^\/\]@#?]+\])(?:[:]([0-9]+))?))?)?)?((\/?(?:[^\/\?#]+\/+)*)([^\?#]*)))?(?:\?([^#]+))?)(?:#(.*))?/;

    /**
      build Url from String
     **/
    @:from 
    public static function fromString(s: String):Url {
        return parse(s, true);
    }

    /**
      parse a Url object from a String
     **/
    public static function parse(s:String, parseQueryString:Bool):Url {
        if (!pattern.match( s ))
            throw 'unable to parse "$s" to Url';

        var port = pattern.matched(12),
        o:Url = {
            protocol : pattern.matched(4),
            slashes: pattern.matched(5) == "//",
            auth: pattern.matched(7),
            hostName: pattern.matched(11),
            port: (null == port) ? null : Std.parseInt(port),
            pathName: pattern.matched(13),
            queryString: null,
            search: null,
            hash: pattern.matched(17)
        };
        o.search = pattern.matched(16);
        return o;
    }

    /**
      Matches all the URL parts with anthat URL and returns true if they are all
      equals.
     */
    @:op(A == B)
    public static function equals(self:Url, that:Url):Bool {
        return self.equalsTo(that);
    }

    /**
      check for strict equality between [this] and [that]
     **/
    public function equalsTo(that: Url):Bool {
        return (
            this.protocol == that.protocol &&
            this.slashes == that.slashes &&
            this.auth == that.auth &&
            this.hostName == that.hostName &&
            this.port == that.port &&
            this.pathName == that.pathName &&
            this.queryString.equals(that.queryString) &&
            this.search == that.search &&
            this.hash == that.hash
        );
    }

    /**
      concatenate [this] and [that]
     **/
    @:op(A / B)
    public function concatString(that: String):Url {
        var copy:Url = clone();
        if (pathName.empty()) {
            if (!that.startsWith("/"))
                that = ("/" + that);
            copy.pathName = that;
        } 
        else {
            if (that.startsWith("/"))
                that = that.substring(1);

            if (pathName.endsWith("/"))
                copy.pathName = (copy.pathName + that);
            else
                copy.pathName = (copy.pathName + "/" + that);
        }
        return copy;
    }

    /**
      convert [this] to a readable String
     **/
    @:to 
    public function toString():String {
        if ( isAbsolute ) {
            return '${hasProtocol ? protocol + ":" : ""}${slashes?"//":""}${hasAuth?auth+"@":""}$host$path${hasHash?"#"+hash:""}';
        }
        else {
            return '$path${hasHash?"#"+hash:""}';
            return path + (hasHash ? '#': '');
        }
    }

    /**
      create and return a deep copy of [this]
     **/
    public function clone():Url {
        return {
            protocol: protocol,
            slashes: slashes,
            auth: auth,
            hostName: hostName,
            port: port,
            pathName: pathName,
            queryString: queryString.clone(),
            search: search,
            hash: hash
        };
    }

    /**
      factory method
     **/
    public static inline function create(?proto:Null<String>, host:Null<String>, ?port:Int, ?path:String, ?query:Either<QueryString, String>, ?hash:String):Url {
        return fromNullableUrl(_n(proto, host, port, path, query, hash));
    }

    @:from
    public static function fromNullableUrl(info: NUrlType):Url {
        return init(null2Init(info));
    }

    public static function _n(?proto:Null<String>, host:Null<String>, ?port:Int, ?path:String, ?query:Either<QueryString, String>, ?hash:String):NUrlType {
        var n:NUrlType = {};
        n.protocol = proto;
        n.hostName = host;
        n.port = port;
        n.pathName = path;
        if (query != null) {
            if ((query is String)) {
                var qs = try QueryString.parse('' + query) catch(e : Dynamic) null;
                if (qs == null)
                    n.search = query;
            }
            else if ((query is IMap)) {
                n.queryString = cast(query, haxe.ds.StringMap<Dynamic>);
            }
        }
        n.hash = hash;
        trace( n );
        return n;
    }

    /**
      create a new Url instance from a UrlInitType object
     **/
    public static function init(init: UrlInitType):Url {
        return cast {
            protocol: init.protocol.getValue(),
            slashes: init.slashes.getValue(),
            auth: init.auth.getValue(),
            hostName: init.hostName.getValue(),
            port: init.port.getValue(),
            pathName: init.pathName.getValue(),
            queryString: init.queryString.getValue(),
            search: init.search.getValue(),
            hash: init.hash.getValue()
        };
    }

    /**
      convert a NullableUrlType object to a UrlInitType object
     **/
    public static function null2Init(t: NUrlType):UrlInitType {
        inline function opt<T>(v: Null<T>):Option<T> {
            return (v == null ? None : Some(v));
        }

        inline function so(?v: String):Option<String> {
            return opt(v.nullEmpty());
        }

        var t = _null2url( t );
        
        return {
            protocol: so(t.protocol),
            slashes: opt(t.slashes),
            auth: so(t.auth),
            hostName: so(t.hostName),
            port: opt(t.port),
            pathName: so(t.pathName),
            queryString: opt(t.queryString),
            search: so(t.search),
            hash: so(t.hash)
        };
    }

    /**
      transform [n] (UrlType, but the properties are optional) into UrlType object
     **/
    public static function _null2url(n: NUrlType):UrlType {
        /**
          convert null values to empty strings
         **/
        inline function en(?s: String):String {
            return (s == null ? '' : s);
        }

        /**
          throw the result as an error
         **/
        function betty(n: NUrlType) {
            throw Option.Some({
                protocol: en(n.protocol),
                slashes: (n.slashes != null ? n.slashes : !en(n.protocol).empty()),
                auth: en(n.auth),
                hostName: en(n.hostName),
                port: n.port,
                pathName: en(n.pathName),
                queryString: n.queryString,
                search: en(n.queryString),
                hash: en(n.hash)
            });
        }

        try {
            switch n {
                case {protocol:_,slashes:_,auth:_,hostName:hn,port:_,pathName:pn,queryString:_,search:_,hash:_}:
                   /* [hostName, pathName] */
                   var hp = [en('' + hn), en('' + pn)];
                   hp = hp.map.fn(_.trim()).map.fn(_.nullEmpty());

                   switch hp {
                       case [null, null]:
                           throw 'Error: Cannot resolve Url data from the given object ($n)';

                       case [_, _]:
                           betty( n );
                   }

                case _:
                   betty( n );
            }

            return null;
        }
        catch (o : Option<Dynamic>) {
            switch o {
                case Option.Some(value) if (Reflect.isObject(value)):
                    return (value : UrlType);

                case _:
                    #if js
                    js.Lib.rethrow();
                    #elseif neko
                    neko.Lib.rethrow();
                    #elseif cs
                    cs.Lib.rethrow();
                    #elseif cpp
                    cpp.Lib.rethrow();
                    #end
                    throw o;
            }
        }
        catch (error: Dynamic) {
            #if js
            js.Lib.rethrow();
            #elseif neko
            neko.Lib.rethrow();
            #elseif cs
            cs.Lib.rethrow();
            #elseif cpp
            cpp.Lib.rethrow();
            #end
            throw error;
        }
    }

    /**
      creates a new QueryString if none previously existed
      returns QueryString
     **/
    public function ensureQueryString():QueryString {
        if (this.queryString != null)
            return this.queryString;
        else
            return queryString = new Map();
    }

/* === Properties === */

    /**
      [auth] property
     **/
    public var auth(get, set) : String;
    inline function get_auth() return this.auth;
    inline function set_auth(value : String) return this.auth = value;

    /**
      [hash] property
     **/
    public var hash(get, set) : String;
    inline function get_hash() return this.hash;
    inline function set_hash(value : String) return this.hash = value;

    public var hasAuth(get, never) : Bool;
    inline function get_hasAuth() return this.auth != null;

    public var hasHash(get, never) : Bool;
    inline function get_hasHash() return this.hash != null;

    public var hasPort(get, never) : Bool;
    inline function get_hasPort() return this.port != null;

    public var hasProtocol(get, never) : Bool;
    inline function get_hasProtocol() return this.protocol != null;

    public var hasQueryString(get, never) : Bool;
    inline function get_hasQueryString() return this.queryString != null && !this.queryString.isEmpty();

    public var hasSearch(get, never) : Bool;
    inline function get_hasSearch() return this.search != null || hasQueryString;

    /**
      [host] property
     **/
    public var host(get, set) : String;
    inline function get_host() return this.hostName + (hasPort ? ':$port' : "");
    inline function set_host(host : String) {
        var p = host.indexOf(":");
        if (p < 0) {
            this.hostName = host;
            this.port = null;
        } 
        else {
            this.hostName = host.substring(0, p);
            this.port = Std.parseInt(host.substring(p + 1));
        }
        return host;
    }

    /**
      [hostName] property
     **/
    public var hostName(get, set) : String;
    inline function get_hostName() return this.hostName;
    inline function set_hostName(hostName : String) return this.hostName = hostName;

    /**
      [href] property
     **/
    public var href(get, set) : String;
    function get_href() return toString(); 
    inline function set_href(value : String) {
        this = (parse(value, true) : UrlType);
        return value;
    }

    /**
      [isAbsolute] property
     **/
    public var isAbsolute(get, never) : Bool;
    inline function get_isAbsolute() return this.hostName != null;

    /**
      [isRelative] property
     **/
    public var isRelative(get, never) : Bool;
    inline function get_isRelative() return this.hostName == null;

    /**
      [path] property
     **/
    public var path(get, set) : String;
    inline function get_path() return (this.pathName + (hasSearch ? '?$search' : ""));
    inline function set_path(value : String) {
        var p = value.indexOf("?");
        if (p < 0) {
            this.pathName = value;
            this.search = null;
            this.queryString = null;
        } 
        else {
            this.pathName = value.substring(0, p);
            search = value.substring(p + 1);
        }
        return value;
    }

    /**
      [pathName] property
     **/
    public var pathName(get, set) : String;
    inline function get_pathName() return this.pathName;
    inline function set_pathName(value : String) return this.pathName = value;

    /**
      [port] property
     **/
    public var port(get, set) : Null<Int>;
    inline function get_port() return this.port;
    inline function set_port(value) return this.port = value;

    /**
      [protocol] property
     **/
    public var protocol(get, set) : String;
    inline function get_protocol() return this.protocol;
    function set_protocol(value : String) return this.protocol = null == value ? null : value.toLowerCase();

    /**
      [params] property
     **/
    public var params(get, set): QueryString;
    inline function get_params() return queryString;
    inline function set_params(v) return queryString = v;

    /**
      [queryString] property
     **/
    public var queryString(get, set) : QueryString;
    inline function get_queryString() return this.queryString;
    inline function set_queryString(value : QueryString) {
        if (null != value)
            this.search = null;
        return this.queryString = value;
    }

    /**
      [search] property
     **/
    public var search(get, set) : String;
    function get_search():String {
        if (null != this.search && "" != this.search) {
            return this.search;
        }
        else {
            return this.queryString.toString();
        }
    }
    function set_search(value : String) {
        var qs = try QueryString.parse(value) catch(e : Dynamic) null;
        if (qs == null || qs.isEmptyOrMono()) {
            this.search = value;
            this.queryString = null;
        } 
        else {
            this.queryString = qs;
            this.search = null;
        }
        return value;
    }

    /**
      [slashes] property
     **/
    public var slashes(get, set) : Bool;
    inline function get_slashes() return this.slashes;
    inline function set_slashes(value : Bool) return this.slashes = value;
}

typedef UrlType = {
    //'http://user:pass@host.com:8080/p/a/t/h?query=string#hash'
    protocol : String,
    slashes: Bool,
    auth: String,
    hostName: String,
    port: Null<Int>,
    pathName: String,
    queryString: QueryString,
    search: String, // for unparsable query string
    hash: String
}

typedef NUrlType = {
    ?protocol : String,
    ?slashes: Bool,
    ?auth: String,
    ?hostName: String,
    ?port: Null<Int>,
    ?pathName: String,
    ?queryString: QueryString,
    ?search: String,
    ?hash: String
};

typedef UrlInitType = {
    protocol : Option<String>,
    slashes: Option<Bool>,
    auth: Option<String>,
    hostName: Option<String>,
    port: Option<Int>,
    pathName: Option<String>,
    queryString: Option<QueryString>,
    search: Option<String>, // for unparsable query string
    hash: Option<String>
}
