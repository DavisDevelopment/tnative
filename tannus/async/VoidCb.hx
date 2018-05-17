package tannus.async;

import tannus.FunctionTools;

using tannus.FunctionTools;

@:callable
abstract VoidCb (?Dynamic->Void) from ?Dynamic->Void {
    /* Constructor Function */
    public inline function new(f : ?Dynamic->Void):Void {
        this = f;
    }

    /**
      wrap [this] callback function
     **/
    public function wrap(body:VoidCb->?Dynamic->Void):VoidCb {
        function _wrapped(?error: Dynamic) {
            body(this, error);
        }
        return new VoidCb(_wrapped);
    }
    private inline function _wrap(body:VoidCb->?Dynamic->Void):VoidCb return new VoidCb( this ).wrap( body );

    /**
      ensure that [this] callback will be called with an error after [time_ms] milliseconds
     **/
    public function timeout(time_ms:Int, ?err:Dynamic, ?id:String):VoidCb {
        if (id == null) {
            id = 'Callback';
        }
        else {
            id = 'Callback("$id")';
        }

        if (err == null) {
            err = '$id timed out';
        }

        var timer = new haxe.Timer(time_ms);
        timer.run = (function() {
            this( err );
        });

        return _wrap(function(_, ?error:Dynamic) {
            timer.stop();
            _( error );
        });
    }

    /**
      ensure that [this] callback is non-null, replacing it with [noop] if it is
     **/
    public inline function nn():VoidCb {
        return new VoidCb(this != null ? this : VoidCb.noop);
    }

    /**
      actually throw the [error] if one is raised
     **/
    public function toss():VoidCb {
        return _wrap(function(_, ?error) {
            if (error != null) {
                throw error;
            }
            _( error );
        });
    }

    /**
      * VoidCb that does nothing. Great as a default value
      */
    public static function noop(?error: Dynamic):Void {
        if (error != null) {
            trace( error );
        }
    }

    public static function throwIt(?error: Dynamic):Void {
        if (error != null) {
            throw error;
        }
    }

    @:to
    #if python @:native('_void') #end
    public inline function void():Void->Void return f.bind(null);

    @:to
    #if python @:native('_raise') #end
    public inline function raise():Dynamic->Void return untyped f.bind(_);
    
    public var f(get, never):?Dynamic->Void;
    private inline function get_f():?Dynamic->Void return this;
}
