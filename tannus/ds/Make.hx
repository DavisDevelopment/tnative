package tannus.ds;

import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.Type;
import haxe.macro.TypeTools;
import haxe.macro.Context;

using haxe.macro.ExprTools;
using tannus.macro.MacroTools;
using tannus.ds.ArrayTools;

class Make {
    /**
      build and return a function which constructs and returns an object of the type described by the given argument
     **/
    macro public static function constructor(expr:ExprOf<{}>, rest:Array<Expr>) {
        var tparams = switch rest {
            case []: null;
            case exprs: exprs.mapi(function(e:Expr, i:Int) {
                return switch e {
                    case macro $i{tname}: tname;
                    case _: Context.error("Make.constructor\'s type-parameter arguments must be identifiers", Context.currentPos());
                }
            });
        }

        var items = switch expr.expr {
            case EObjectDecl(fields):
                fields.mapi(function(v, i) return extractFieldFromLiteral(v, i));

            case EConst(CIdent(type)):
                switch Context.getType(type) {
                    case TType(t, params):
                        var type = t.get(),
                        meta = type.meta;
                        switch type.type {
                            case TAnonymous(anonym):
                                var seqMeta = meta.extract(":sequence");
                                var sequence = seqMeta.map(m -> m.params.map(ExprTools.toString)).flatten();
                                var mkfields = anonym.get().fields.map(f -> extractFieldAnonymous(f, sequence));
                                var pnames = params.map(t -> TypeTools.toString( t ));
                                mkfields.map(function(field) {
                                    for (i in 0...pnames.length) {
                                        if (field.type == pnames[i]) {
                                            field.type = tparams[i];
                                        }
                                    }
                                    return field;
                                });

                            case _:
                                Context.error("Make.constructor can only take a reference to a typedef that represent an object literal", Context.currentPos()); [];
                        }

                    case _:
                        Context.error("Make.constructor can only take a reference to a typedef that represent an object literal", Context.currentPos()); [];
                }

            case other:
                Context.error("Make.constructor only accepts anonymous objects with type names as values or a reference to a typedef", Context.currentPos()); [];
        }

        items.sort(function(a, b) {
            return Reflect.compare(a.weight, b.weight);
        });

        var args = items.map(item -> (item.optional ? "?" : "") + '${item.field} : ${item.type}'),
        assign = items.filter(item -> !item.optional).map(item -> '${item.field} : ${item.field}'),
        types  = items.map(item -> (item.optional ? "@:optional " : "") + 'var ${item.field} : ${item.type};'),
        type   = "{ " + types.join(" ") + " }",
        fun    = 'function constructor(${args.join(", ")}) {\n  var obj : $type = {\n    ${assign.join(",\n    ")}\n  };';
        fun += items.filter(item -> item.optional).map(item -> '\n  if(null != ${item.field}) obj.${item.field} = ${item.field};').join("");
        fun += "\n  return obj;\n}";
        return Context.parse(fun, Context.currentPos());
    }

#if macro

    static function extractFieldFromLiteral(field, weight:Float) {
        switch field.expr.expr {
            case EConst(CIdent(type)):
                return {
                    field: field.field,
                    type: type,
                    weight: weight,
                    optional: false
                };

            case EConst(CString(str_type)):
                return  {
                    field: field.field,
                    type: str_type,
                    weight: weight,
                    optional: false
                };

            case _:
                Context.error("Make.constructor fields can only have values that represent types", Context.currentPos());
                return null;
        }
    }

    static function extractFieldAnonymous(field:ClassField, sequence:Array<String>) {
        var pos : Float = sequence.indexOf(field.name);
        var weights = field.meta.extract(":weight").map(e -> e.params.map(ExprTools.toString)).flatten();
        if (weights.length > 0)
            pos = Std.parseFloat(weights[0]);

        return {
            field: field.name,
            type: TypeTools.toString(field.type),
            weight: pos,
            optional: field.meta.has(":optional")
        };
    }

#end
}

private typedef MkField = {field:String, type:String, weight:Float, optional:Bool};
