package tannus.async;

import tannus.async.Future;

using tannus.async.Asyncs;
using tannus.async.Result;

@:forward
abstract Futuristic <Res, Err> (Future<Res, Err>) from Future<Res, Err> to Future<Res, Err> {
    @:from
    public static function fromResult<Res, Err>(result: Result<Futuristic<Res, Err>, Err>):Futuristic<Res, Err> {
        return new Future<Res, Err>(function(future) {
            switch result {
                case ResSuccess(value):
                    value.then(function(resolution: Result<Res, Err>) {
                        switch resolution {
                            case ResSuccess(res):
                                future.yield( res );

                            case ResFailure(err):
                                future.raise( err );
                        }
                    });

                case ResFailure(err):
                    future.raise( err );
            }
        });
    }

    @:from
    public static inline function fromPromise<T>(promise: Promise<T>):Futuristic<T, Dynamic> {
        return promise.future(null);
    }

    @:from
    public static inline function fromAny<T>(v: T):Futuristic<T, Dynamic> {
        return Future.resolve( v );
    }
}
