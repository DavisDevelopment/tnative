package tannus.http;

import tannus.io.*;
import tannus.http.*;
import tannus.ds.Object;

import tannus.sys.Mime;

class BaseRequest {
    /* Constructor Function */
    public function new(href:Url, ?meth:String):Void {
        url = href;
        method = (meth != null ? meth.toUpperCase() : 'GET');
        reqHeaders = new Map();
        resHeaders = new Map();
        reqData = null;
    }
    
/* === Instance Methods === */

    /* send [this] Request */
    public function send(complete : ByteArray -> Void):Void {
        complete('');
    }
    
    /* assign [reqData] */
    public function write(dat : ByteArray):Void {
        reqData = dat;
    }
    
    /* set the content-type */
    public function contentType(type : Mime):Void {
        reqHeaders['content-type'] = (type + '');
    }
    
    /* set the user-agent */
    public function userAgent(name : String):Void {
        reqHeaders['user-agent'] = name;
    }
    
/* === Instance Fields === */

    public var url : Url;
    public var method : String;
    public var status : Int;
    public var reqData : Null<ByteArray>;
    public var reqHeaders : Map<String, Dynamic>;
    public var resHeaders : Map<String, Dynamic>;
}