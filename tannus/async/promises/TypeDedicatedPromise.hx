package tannus.async.promises;

import tannus.ds.Delta;
import tannus.io.Signal;
import tannus.io.Signal2;

import tannus.async.Promise;

import haxe.extern.EitherType as Either;
import haxe.macro.Expr;
import haxe.macro.Context;

import Slambda.fn;
import Reflect.deleteField;

using Slambda;
using haxe.macro.ExprTools;
using tannus.macro.MacroTools;

class TypeDedicatedPromise<T> extends DerivedPromise<T, T> {
    /* Constructor Function */
    public function new(parent:Promise<T>, ?ext:Promise<T>->(PromiseResolution<T>->Void)->(Dynamic->Void)->Void):Void {
        super(function(_super, yes, no) {
            if (ext == null)
                _super.then(yes, no);
            else
                ext(_super, yes, no);
        }, parent);
    }

/* === Instance Methods === */

    /**
      * lambda transform
      */
    public macro function ltf<TOut>(self:ExprOf<Promise<T>>, trans:Expr, rest:Array<Expr>):ExprOf<TOut> {
        var outClass:Null<Expr> = null;
        var argName:Null<String> = null;
        
        // handle [rest] arguments
        switch ( rest ) {
            case [{pos:_,expr:rex}]:
                switch ( rex ) {
                    case EConst(CIdent(_)), EField(_, _):
                        outClass = rest[0];

                    default:
                        null;
                }

            default:
                null;
        }

        // handle [trans]
        switch ( trans.expr ) {
            case EBinop(OpArrow, _.expr=>EConst(CIdent(name)), rightExpr):
                argName = name;
                trans = rightExpr;

            default:
                null;
        }

        // handle argument-expression mapping
        if (argName == null) {
            trans = trans.replace(macro _, macro x);
            argName = 'x';
        }
        else {
            null;
        }

        // create Function expression
        trans = trans.buildFunction([argName]);

        // create return-value expression
        var outExpr:Expr = (macro $self.transform( $trans ));

        // handle wrapping that expression in a class-construction expression
        //if (outClass != null) {
            //outExpr = (macro new $outClass($outExpr));
        //}

        return outExpr;
    }
}
