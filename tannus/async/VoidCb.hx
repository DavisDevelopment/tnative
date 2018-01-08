package tannus.async;

import tannus.FunctionTools;

using tannus.FunctionTools;

@:callable
abstract VoidCb (?Dynamic->Void) from ?Dynamic->Void {
    public inline function new(f : ?Dynamic->Void):Void {
        this = f;
    }

    public inline function wrap(body:VoidCb->?Dynamic->Void):VoidCb {
        return body.bind(this, _);
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
