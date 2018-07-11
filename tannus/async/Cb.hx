package tannus.async;

@:forward
@:callable
abstract Cb<T> (Callback<T, Dynamic>) from Callback<T, Dynamic> {
    public inline function new(f : Callback<T,Dynamic>) {
        this = f;
    }

    @:to
    #if python @:native('_raise') #end
    public inline function raise():Dynamic->Void return this.raise();
    @:to
    #if python @:native('_yield') #end
    public inline function yield():T->Void return this.yield();
    @:to
    #if python @:native('_void') #end
    public inline function toVoid():Void->Void return this.toVoid();

    public inline function nn():Cb<T> {
        return new Cb(this != null ? this : Cb.noop);
    }

    public static function noop<T>(?error:Dynamic, ?value:T):Void {
        if (error != null) {
            #if (js && debug)
                js.Lib.global.console.error( error );
            #end
            //trace( error );
        }
        else if (value != null) {
            //trace( value );
        }
    }
}

