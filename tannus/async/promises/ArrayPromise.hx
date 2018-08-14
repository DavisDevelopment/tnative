package tannus.async.promises;

import tannus.ds.Delta;
import tannus.io.Signal;
import tannus.io.Signal2;

import tannus.async.Promise;

import haxe.extern.EitherType as Either;

import Slambda.fn;
import Reflect.deleteField;

using Slambda;
using tannus.ds.ArrayTools;

class ArrayPromise<T> extends TypeDedicatedPromise<Array<T>> {
    //private static inline function array<T>(a : Promise<Array<T>>):ArrayPromise<T> return new ArrayPromise( a );

    public function get(index : Int):Promise<T> return transform.fn(_[index]);
    //public function slice(pos:Int, ?end:Int):ArrayPromise<T> return array(transform.fn(_.slice(pos, end)));
    public function slice(pos:Int, ?end:Int):ArrayPromise<T> return ltf(_.slice(pos, end)).array();
    public function concat(other : PromiseResolution<Array<T>>):ArrayPromise<T> {
        return Promise.create({
            var err = (function(e:Dynamic) throw e);
            var resArr:Array<T> = new Array();
            then(function(a) {
                resArr = resArr.concat( a );
                Promise.resolve(other).then(function(b) {
                    resArr = resArr.concat( b );
                    
                    return resArr;
                }, err);
            }, err);
        }).array();
    }
    public function filter(test : T->Bool):ArrayPromise<T> return ltf(_.filter(test)).array();
    public function join(sep:String):StringPromise return ltf(_.join(sep)).string();
    public function each(action:T->Void):ArrayPromise<T> {
        then(function(list) {
            for (item in list) {
                action( item );
            }
        });
        return this;
    }

    public function vmap<TOut>(f : T->TOut):ArrayPromise<TOut> {
        return ltf(_.map( f )).array();
    }
}
