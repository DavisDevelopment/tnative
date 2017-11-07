package tannus.async;

import tannus.ds.*;

@:callable
abstract Async<T> (Cb<T>->Void) from Cb<T>->Void {
    public inline function new(f : Cb<T>->Void)
        this = f;

    @:to
    public function promise():Promise<T> {
        return new Promise(function(yield, raise) {
            this(function(?error, ?result) {
                if (error != null)
                    return raise( error );
                else {
                    return yield( result );
                }
            });
        });
    }

    @:to
    public function promiser():Void->Promise<T> {
        return promise.bind();
    }
}
