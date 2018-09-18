package tannus.async;

import tannus.async.Promise;

class UnscopedPromise<T> extends Promise<T> {
    /* Constructor Function */
    public function new():Void {
        super(function(_yes, _no) {
            this.fn = {
                accept: _yes,
                reject: _no
            };
        });
    }

/* === Instance Methods === */

    public function accept(value: PromiseResolution<T>):UnscopedPromise<T> {
        fn.accept( value );
        return this;
    }

    public function reject(error: Dynamic):UnscopedPromise<T> {
        fn.reject( error );
        return this;
    }

/* === Instance Fields === */

    private var fn(default, null): UnscopedPromiseFuncs<T>;
}

private typedef UnscopedPromiseFuncs<T> = {
    var accept: PromiseResolution<T> -> Void;
    var reject: Dynamic -> Void;
}
