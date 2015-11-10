package tannus.http;

import tannus.io.*;
import tannus.ds.Object;
import tannus.node.Http;
import tannus.node.IncomingMessage;
import tannus.node.Buffer;
import tannus.http.Url;
import tannus.http.BaseRequest;

class NodeRequest extends BaseRequest {
    /* Constructor Function */
    public function new(href:Url, ?meth:String):Void {
        super(href, meth);
        
        _data = new Signal();
    }
    
/* === Instance Methods === */

    /**
      * Build a node-js http request from [this] model
      */
    private function pack():Void {
        var opts:Object = buildOptions();
        trace( opts );
        
        /* function to handle incoming data for [this] Request */
        function pack_cb(res : IncomingMessage):Void {
            /* get the status-code and response-headers */
            status = res.statusCode;
            resHeaders = cast (new Object(res.headers)).toMap();
            
            /* get the response body */
            var result:ByteArray = new ByteArray();
            res.on('data', function(chunk : Buffer) {
                result.write( chunk );
            });
            res.on('end', function() {
                _data.call( result );
            });
        }
        
        // create the request
        var req = Http.request(opts, pack_cb);
        
        /* if [reqData] is defined, write it to the request */
        if (reqData != null) {
            req.write( reqData );
        }
        
        // finalize the request
        req.end();
    }
    
    private function buildOptions():Object {
        var options:Object = tannus.node.Url.parse( url );
        options = options.plucka([
          'protocol',
          'host',
          'hostname',
          'path'
        ]);
        options['headers'] = Object.fromMap( reqHeaders );
        options['method'] = method;
        return options;
    }
    
    /**
      * Send [this] Request, and await a response
      */
    override public function send(complete : ByteArray -> Void):Void {
        _data.once( complete );
        pack();
    }
    
/* === Instance Methods === */
    
    private var _data : Signal<ByteArray>;
}