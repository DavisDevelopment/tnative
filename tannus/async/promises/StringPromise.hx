package tannus.async.promises;

import tannus.ds.Delta;
import tannus.io.Signal;
import tannus.io.Signal2;

import tannus.async.Promise;

import haxe.extern.EitherType as Either;

import Slambda.fn;
import Reflect.deleteField;

using Slambda;

class StringPromise extends TypeDedicatedPromise<String> {
    public function charAt(index : Int):StringPromise {
        return str(transform.fn(_.charAt( index )));
    }
    public function substr(pos:Int, ?len:Int):StringPromise return str(transform.fn(_.substr(pos, len)));
    public function substring(pos:Int, end:Int):StringPromise return str(transform.fn(_.substring(pos, end)));
    public function toUpperCase():StringPromise return str(transform.fn(_.toUpperCase()));
    public function toLowerCase():StringPromise return str(transform.fn(_.toUpperCase()));

    private static inline function str(p : Promise<String>):StringPromise return new StringPromise( p );
}
