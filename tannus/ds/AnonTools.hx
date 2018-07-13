package tannus.ds;

import tannus.macro.MacroTools;
import tannus.io.*;

import Type;
import Type.ValueType as Vt;
import Type as Types;

import Slambda.fn;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

import Reflect.*;
import Type.*;

using Lambda;
using Slambda;
using tannus.macro.MacroTools;
using haxe.macro.ExprTools;
using haxe.macro.TypeTools;
using haxe.macro.ComplexTypeTools;

class AnonTools {
    /**
      get key=>value pairs
     **/
    public static function pairs(o: Dynamic):Array<Pair<String, Dynamic>> {
        var res = [];
        for (key in Reflect.fields( o )) {
            res.push(new Pair(key, Reflect.field(o, key)));
        }
        return res;
    }

    /**
      * more generic and commonly useful 'owith'
      */
    public static macro function with(o:Expr, action:Expr) {
        var ers:Array<Expr> = new Array();
        switch ( action.expr ) {
            case EBinop(OpArrow, {pos:_,expr:EArrayDecl(names)}, body):
                action = body;
                ers = names;

            case EBinop(OpArrow, name, body):
                action = body;
                ers[0] = name;

            default:
                null;
        }

        switch ( o.expr ) {
            case EArrayDecl( values ):
                for (index in 0...values.length) {
                    var e = values[index];
                    if (ers[index] != null)
                        action = action.replace(ers[index], e);
                    else {
                        var er:Expr = (macro $i{'_' + (index + 1)});
                        action = action.replace(er, e);
                    }
                }

            default:
                if (ers[0] != null)
                    action = action.replace(ers[0], o);
                else
                    action = action.replace(macro _, o);
        }

        return action;
    }

    /**
      * creates and returns a deep-copy of the given object [o]
      * @param structs {Bool} denotes whether or not to attempt to copy class instances and enum values
      */
    public static function deepCopy<T>(o:T, ?target:T, structs:Bool=false):T {
        return clone_dynamic(o, target, structs);
    }

    /**
      clone any type
     **/
    private static function clone_dynamic<T>(o:T, ?target:T, structs:Bool):T {
        var vtype:ValueType = Types.typeof( o );
        switch ( vtype ) {
            // basemost atomic types
            case TNull, TBool, TFloat, TInt:
                return o;

            // anonymous object value
            case Vt.TObject:
                return clone_anon(o, structs, target);

            // enum value
            case Vt.TEnum( e ):
                //var ev:EnumValue = cast o;
                return clone_enumvalue(o, cast e, structs);

            // class instance
            case Vt.TClass( c ):
                return clone_instance(o, cast c, structs, target);

            case Vt.TFunction:
                // probably a few more targets for which something like this would work..
                #if js
                    // create an unbound copy of [o]
                    return cast ((untyped o).bind(null));
                #else
                    throw 'TypeError: Cannot copy a function value';
                #end

            // unknown type
            case Vt.TUnknown:
                trace('Warning: Unknown, non-cloneable value', o);
                return o;
        }
    }

    /**
      * create a deep-clone of an anonymous object
      */
    private static function clone_anon(o:Dynamic, structs:Bool, ?d:Dynamic):Dynamic {
        var res:Dynamic = (d != null ? d : {});
        var val:Dynamic;
        for (k in fields( o )) {
            val = deepCopy(field(o, k), null, structs);
            // on the js-target
            #if js
                // if [k] is a method-property
                if (isFunction( val )) {
                    // rebind [val] to the created clone
                    val = (untyped val).bind(res);
                }
            #end
            setField(res, k, val);
        }
        return res;
    }

    /**
      * create deep-clone of a class-instance
      */
    private static function clone_instance<T>(o:T, type:Class<T>, structs:Bool, ?target:T):T {
        if (type == (String : Class<Dynamic>)) {
            return o;
        }
        else if (type == (Array : Class<Dynamic>)) {
            return untyped {
                (o : Array<Dynamic>).map(deepCopy.bind(_, null, structs));
            };
        }
        else {
            if (hasField(o, 'clone') && isFunction(field(o, 'clone'))) {
                return (untyped o.clone)();
            }
            else if ( structs ) {
                var copi:T = (target != null ? target : createEmptyInstance( type ));
                clone_anon(o, structs, copi);
                return copi;
            }
            else {
                return o;
            }
        }
    }

    /**
      * create deep-clone of an enum-value
      */
    private static function clone_enumvalue<T>(o:T, type:Enum<T>, structs:Bool):T {
        var vt:EnumValue = cast o;
        if (type.createAll().has( o )) {
            return o;
        }
        else {
            if ( structs ) {
                return untyped {
                    createEnum(type, vt.getName(), (vt.getParameters().map(deepCopy.bind(_, null, structs))));
                };
            }
            else {
                return o;
            }
        }
    }

    private static function all_instance_fields<T>(type:Class<T>):Set<String> {
        var props:Set<String> = new Set();
        var parent = getSuperClass( type );
        if (parent != null) {
            props.pushMany(all_instance_fields( parent ));
        }
        props.pushMany(getInstanceFields( type ));
        return props;
    }

	/**
	  * 'with'
	  */
	public static macro function owith<T>(o:ExprOf<T>, action:Expr) {
		//var type = Context.typeof( o ).getClass();
		//var tvars = Context.getLocalTVars();
		var mixins = Context.getLocalUsing();
		var type = Context.typeof( o );
		var pos = Context.currentPos();

		var map = typeFields( type );
		for (module in mixins) {
		    mixinFields(type, module, map);
        }

		var out:Expr = action;
		for (name in map.keys()) {
			var ident:Expr = macro $i{name};
            var field:Expr = {
                pos: Context.currentPos(),
                expr: ExprDef.EField(o, name)
            };
			//var field:Expr = macro $o.$name;
		    
			out = withReplace(out, ident, field);
		}

		return out;
	}

#if macro

    private static function mixinFields(type:Type, mref:Ref<ClassType>, ?m:Map<String, ClassField>):Map<String, ClassField> {
        if (m == null)
            m = new Map();

        var mixin = mref.get();
        // mixin methods
        var mm = mixin.statics.get();
        mm = mm.filter(function(field) {
            return field.kind.match(FMethod(_));
        })
        .filter(function(field) {
            switch ( field.type ) {
                case TFun(_[0]=>arg1, _) if (arg1 != null):
                    if (type.equals(arg1.t)) {
                        return true;
                    }
                    else if (Context.unify(type, arg1.t)) {
                        return true;
                    }

                case _:
                    return false;
            }
            return false;
        });

        for (f in mm)
            m.set(f.name, f);
        return m;
    }

    private static function typeFields(type:Type, ?m:Map<String, ClassField>):Null<Map<String, ClassField>> {
        if (m == null)
            m = new Map();

		switch ( type ) {
            case Type.TInst(_.get()=>ctype, params):
                tfclass(ctype, m);

            case Type.TAnonymous(_.get() => atype):
                tfanon(atype, m);

            case Type.TAbstract(_.get()=>btype, params):
                tfabstract(btype, m);

            //case Type.TEnum(_.get()=>etype, params):
                //etype.constructs

            case Type.TType(_.get()=>ttype, params):
                typeFields(ttype.type, m);

            case other:
                return null;
		}

		var scoped = false;
		for (fieldName in m.keys()) {
		    scoped = true;
		    break;
		}
		if (!scoped)
		    return null;
		return m;
    }
    private static function tfclass(c:ClassType, m:Map<String, ClassField>) {
        for (f in c.fields.get())
            m.set(f.name, f);
    }
    private static function tfabstract(a:AbstractType, m:Map<String, ClassField>) {
        if (a.impl != null) {
            tfclass(a.impl.get(), m);
        }
        else {
            typeFields(a.type, m);
        }
    }
    private static function tfanon(a:AnonType, m:Map<String, ClassField>) {
        for (f in a.fields)
            m[f.name] = f;
    }
    private static function tfenum(e:EnumType, m) {
        for (cn in e.constructs.keys()) {
            m.set(cn, e.constructs.get(cn));
        }
    }

	private static function withReplace(e:Expr, x:Expr, y:Expr):Expr {
		if (e.expr.equals( x.expr )) {
			return y;
		}
		else {
			return e.map(wrMapper.bind(_, x, y));
		}
	}

	private static function wrMapper(e:Expr, x:Expr, y:Expr):Expr {
        switch ( e ) {
            case macro @without $ee:
                return ee;

            case macro @ignore $ee:
                return ee;

            case macro super.$ee:
                return macro $i{ee};

            default:
                if (e.expr.equals(x.expr))
                    return y;
                else
                    return e.map(wrMapper.bind(_, x, y));
        }
        /*
		switch ( e.expr ) {
			case EMeta(s, ee) if (s.name == 'ignore'):
				return ee;

			default:
				if (e.expr.equals( x.expr )) {
					return y;
				}
				else {
					return e.map(wrMapper.bind(_, x, y));
				}
		}
		*/
	}

#end
}
