package tannus.async;

import tannus.async.Either;

import haxe.ds.Option;

import Reflect.*;
import Type.*;

using StringTools;
using tannus.ds.StringUtils;
using tannus.ds.ArrayTools;
using tannus.FunctionTools;

enum Result <TSuccess, TFailure> {
    ResSuccess(value: TSuccess);
    ResFailure(value: TFailure);
}

class ResultTools {
    public static function toEither<Y,N>(result: Result<Y, N>):Either<Y, N> {
        return (switch ( result ) {
            case ResSuccess(yes): Left( yes );
            case ResFailure(no): Right( no );
        });
    }

    public static inline function isSuccess<Yes, No>(result: Result<Yes, No>):Bool {
        return result.match(ResSuccess(_));
    }

    public static inline function isFailure<Yes, No>(result: Result<Yes, No>):Bool {
        return result.match(ResFailure(_));
    }

    public static function error<Yes,No>(result:Result<Yes,No>):Null<No> {
        return (switch (result) {
            case ResFailure(x): x;
            default: null;
        });
    }

    public static function value<Yes,No>(result:Result<Yes,No>):Null<Yes> {
        return (switch (result) {
            case ResSuccess(x): x;
            default: null;
        });
    }

    public static function optionError<Yes,No>(result:Result<Yes,No>):Option<No> {
        return (switch (result) {
            case ResFailure(x): Some( x );
            default: None;
        });
    }

    public static function optionValue<Yes,No>(result:Result<Yes,No>):Option<Yes> {
        return (switch (result) {
            case ResSuccess(x): Some( x );
            default: None;
        });
    }
}
