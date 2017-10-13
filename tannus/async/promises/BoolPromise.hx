package tannus.async.promises;

import tannus.ds.Delta;
import tannus.io.Signal;
import tannus.io.Signal2;

import tannus.async.Promise;

import haxe.extern.EitherType as Either;

import Slambda.fn;
import Reflect.deleteField;

using Slambda;

class BoolPromise extends TypeDedicatedPromise<Bool> {
    private static inline function boolean(p : Promise<Bool>):BoolPromise return new BoolPromise( p );

    public function yep(action : Void->Void):Void {
        then(function(result : Bool) {
            if ( result )
                action();
        });
    }

    public function nope(action : Void->Void):Void {
        then(function(result : Bool) {
            if ( !result )
                action();
        });
    }
}
