package tannus.macro;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.macro.Type;
import haxe.macro.Expr.ComplexType;
import haxe.macro.Expr.Field;
import haxe.macro.Expr.FieldType;
import haxe.macro.Expr.Access;
import haxe.macro.Expr.Metadata;
import haxe.macro.Expr.MetadataEntry;

using haxe.macro.ExprTools;
using haxe.macro.TypeTools;
using haxe.macro.ComplexTypeTools;
using haxe.macro.ExprTools.ExprArrayTools;
using tannus.macro.MacroTools;

class ProxierBuilder {
	/* build the Proxier type's magic */
	public static macro function build():Array<Field> {
		var fields = Context.getBuildFields();
		var ltype = Context.getLocalClass().get();
		var fullTypeName = ltype.fullName();
		var results = new Array();

		for (f in fields) {
			switch ( f.kind ) {
				case FVar(fieldType, fieldExpr) if (f.meta != null):
					var res = scanMetaData(f, fullTypeName);
					results = results.concat( res );
				
				default:
					results.push( f );
			}
		}

		return results;
	}

#if macro

	/**
	  * determine how to manipulate the given Field, based on it's metadata
	  */
	private static function scanMetaData(field:Field, ftn:String):Array<Field> {
		var generated:Array<Field> = new Array();
		var type:Null<ComplexType> = getFieldType( field );
		var f:Field = cloneField( field );

		for (entry in field.meta) {
			switch ( entry.name ) {
				case 'proxy':
					// Compiler.keep( ftn );
					switch ( entry.params ) {
						/* most basic proxy -- forward */
						case [ getExpr ]:
							var get:Expr = getExpr;
							/* if the proxy is to a constant, only supply a getter */
							if (get.isConstant()) {
								f.kind = FProp('get', 'null', type, null);
								generated.push( f );
								generated.push(getterField(f.name, get, type));
							}
							else {
								f.kind = FProp('get', 'set', type, null);
								generated.push( f );
								generated.push(getterField(f.name, get, type));
								var setterField:Field = {
									'pos' : field.pos,
									'name': ('set_' + field.name),
									'meta': null,
									'kind': FFun(setterFunction(get, type)),
									'doc': null,
									'access': [APrivate, AInline]
								};
								generated.push( setterField );
							}

						case [getExpr, setExpr]:
							var gete_type = typeof( getExpr ).toComplexType();
							if (setExpr.has(macro _)) 
								setExpr = setExpr.replace(macro _, macro v);
							f.kind = FProp('get', 'set', type, null);
							generated.push( f );
							var getterField:Field = {
								'pos' : field.pos,
								'name': ('get_' + field.name),
								'meta': null,
								'kind': FFun(getterFunction(getExpr, type)),
								'doc' : null,
								'access': [APrivate, AInline]
							};
							generated.push( getterField );
							var setterField:Field = {
								'pos' : field.pos,
								'name': ('set_' + field.name),
								'meta': null,
								'kind': FFun(setterFunction(setExpr, type)),
								'doc': null,
								'access': [APrivate, AInline]
							};
							generated.push( setterField );

						default:
							generated.push( field );
					}
				default:
					generated.push( field );
			}
		}
		return generated;
	}

	/**
	  * Create and return a get_[name] Field
	  */
	private static function getterField(name:String, get:Expr, type:Null<ComplexType>):Field {
		return {
			'pos' : Context.currentPos(),
			'name': ('get_' + name),
			'meta': null,
			'kind': FFun(getterFunction(get, type)),
			'doc' : null,
			'access': [APrivate, AInline]
		};
	}

	/**
	  * build a getter-function to the given Field
	  */
	private static function getterFunction(get:Expr, type:Null<ComplexType>):Function {
		return {
			'params': null,
			'args': new Array(),
			'ret': type,
			'expr': macro {
				return $get;
			}
		};
	}

	private static function setterFunction(set:Expr, type:Null<ComplexType>):Function {
		return {
			'params': null,
			'args': [{value:null, type:type, name:'v', opt:null}],
			'ret': type,
			'expr': macro {
				return $set;
			}
		};
	}

	/**
	  * create and return a clone of [field]
	  */
	public static function cloneField(field : Field):Field {
		var c = {
			'pos'  : field.pos,
			'name' : field.name,
			'meta' : null,
			'kind' : field.kind,
			'doc'  : field.doc,
			'access': field.access.copy()
		};
		if (field.meta != null) {
			c.meta = new Metadata();
			for (m in field.meta) {
				c.meta.push({
					'name': m.name,
					'pos' : m.pos,
					'params': (m.params == null ? null : [for (e in m.params) parseExpr(e.toString())])
				});
			}
		}
		return c;
	}

	public static function getFieldType(f : Field):Null<ComplexType> {
		switch ( f.kind ) {
			case FVar(type, _):
				return type;
			case FProp(_, _, type, _):
				return type;
			case FFun( f ):
				return null;
		}
	}

	/* create an Expr from a String */
	private static function parseExpr(s : String):Expr {
		return Context.parse(s, Context.currentPos());
	}

	/* get the type of the given expression */
	private static function typeof(e : Expr):Type {
		return Context.typeof( e );
	}
#end
}
