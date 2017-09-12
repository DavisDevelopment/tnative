package tannus.ds;

import tannus.io.Ptr;
import tannus.io.Getter;
import tannus.io.Setter;

import Reflect in R;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.Constraints.Function;

using Reflect;
using Lambda;
using tannus.ds.ArrayTools;
using tannus.macro.MacroTools;
using haxe.macro.ExprTools;
using haxe.macro.TypeTools;

@:forward
abstract Obj (CObj) from CObj {
	/* Constructor Function */
	private inline function new(o : Dynamic):Void {
		this = CObj.create(o);
	}

/* === Instance Methods === */

	/**
	  * Cast to Dynamic
	  */
	@:to
	public inline function toDyn():Dynamic return this.o;

	/**
	  * Get an attribute of [this]
	  */
	@:arrayAccess
	public inline function get<T>(key:String):T 
		return this.get(key);

	public inline function mget<T>(key : String):Maybe<T> {
		return this.get( key );
	}

	/**
	  * Set an attribute of [this]
	  */
	@:arrayAccess
	public inline function set<T>(key:String, val:T):T
		return this.set(key, val);

	/**
	  * Define a Property of [this]
	  */
	public macro function define<T>(self:ExprOf<Obj>, args:Array<Expr>):Expr {
		var n:Expr = args.shift();
		
		switch ( n.expr ) {
			case EConst(CString( name )):
				var ref:Expr = args.shift().pointer();
				return macro $self.defineProperty($v{name}, $ref);

			case EConst(CIdent( name )):
				var ref:Expr = n.pointer();
				return macro $self.defineProperty($v{name}, $ref);

			default:
				var sargs:String = args.map(function(e) return e.toString()).join(', ');
				Context.fatalError('Invalid arguments to Obj::define('+sargs+')', Context.currentPos());
				return macro null;
		}
	}

	public macro function property<T>(self:ExprOf<Obj>, args:Array<Expr>):Expr {
		var n:Expr = args.shift();
		
		switch ( n.expr ) {
			case EConst(CString( name )):
				var ref:Expr = args.shift().pointer();
				return macro $self.defineProperty($v{name}, $ref);

			case EConst(CIdent( name )):
				var ref:Expr = n.pointer();
				trace(ref.test());
				return macro $self.defineProperty($v{name}, $ref);

			default:
				var sargs:String = args.map(function(e) return e.toString()).join(', ');
				Context.fatalError('Invalid arguments to Obj::define('+sargs+')', Context.currentPos());
				return macro null;
		}
	}

	public macro function getter<T>(self:ExprOf<Obj>, args:Array<Expr>):Expr {
		var n:Expr = args.shift();
		
		switch ( n.expr ) {
			case EConst(CString( name )):
				var ref:Expr = args.shift();
				ref = macro tannus.io.Getter.create( $ref );
				return macro $self.defineGetter($v{name}, $ref);

			case EConst(CIdent( name )):
				var ref:Expr = n;
				ref = macro tannus.io.Getter.create( $ref );
				return macro $self.defineGetter($v{name}, $ref);

			default:
				var sargs:String = args.map(function(e) return e.toString()).join(', ');
				Context.fatalError('Invalid arguments to Obj::define('+sargs+')', Context.currentPos());
				return macro null;
		}
	}

	public macro function setter<T>(self:ExprOf<Obj>, args:Array<Expr>):Expr {
		var n:Expr = args.shift();
		
		switch ( n.expr ) {
			case EConst(CString( name )):
				var ref:Expr = args.shift();
				ref = macro tannus.io.Setter.create( $ref );
				return macro $self.defineSetter($v{name}, $ref);

			case EConst(CIdent( name )):
				var ref:Expr = n;
				ref = macro tannus.io.Setter.create( $ref );
				return macro $self.defineSetter($v{name}, $ref);

			default:
				var sargs:String = args.map(function(e) return e.toString()).join(', ');
				Context.fatalError('Invalid arguments to Obj::define('+sargs+')', Context.currentPos());
				return macro null;
		}
	}

/* === Class Methods === */

	/**
	  * Implicitly create a new Obj
	  */
	@:from
	public static inline function fromDynamic(d : Dynamic):Obj {
		return CObj.create( d );
	}
}

@:expose( 'tannus.ds.Obj' )
class CObj {
	/* Constructor Function */
	public function new(obj : Dynamic):Void {
		o = obj;
		refCache = new Map();
	}

/* === Instance Methods === */

	/**
	  * Get Array of all keys of [this] Obj
	  */
	public function keys():Array<String> {
		return o.fields();
	}

	/**
	  * Check for the given attribute
	  */
	public inline function exists(key : String):Bool {
		return o.hasField(key);
	}

	/**
	  * Get the value of the given attribute
	  */
	public inline function get<T>(key : String):T {
		return (untyped o.getProperty(key));
	}

	/**
	  * Set the value of the given attribute
	  */
	public function set<T>(key:String, val:T):T {
		o.setProperty(key, val);
		return get(key);
	}

	/**
	  * Get a method
	  */
	public inline function method<T:Function>(name : String):T {
		return untyped o.callMethod.bind(get( name ), _).makeVarArgs();
	}

	/**
	  * Call a method
	  */
	public inline function call<T>(name:String, args:Array<Dynamic>):T {
		return o.callMethod(get(name), args);
	}

	/**
	  * Get a Ptr reference to the given attribute
	  */
	public function field<T>(key : String):Ptr<T> {
		if (refCache.exists(key)) {
			return untyped refCache.get(key);
		}
		else {
			var ref:Ptr<T> = new Ptr(get.bind(key), set.bind(key, _), (function() remove(key)));
			refCache.set(key, untyped ref);
			return ref;
		}
	}

	/**
	  * Delete an attribute of [this]
	  */
	public function remove(key : String):Bool {
		return o.deleteField( key );
	}

	/**
	  * create and return an object with a subset of the properties/values attached to [this] one
	  */
	public function pluck(keys : Array<String>):Obj {
		var co:Dynamic = {};
		var copy:Obj = Obj.fromDynamic( co );
		var path : ObjectPath;
		for (key in keys) {
		    path = new ObjectPath( key );
		    path.set(co, path.get( o ));
        }
		return copy;
	}

	/**
	  * extract a value from [this]
	  */
	public function extract<T>(fieldName : String):T {
	    var key = new ObjectPath( fieldName );
	    return key.get( o );
	}

	/**
	  * create a new anonymous object with the same properties/property-values as [this]
	  */
	public function rawclone():Obj {
		var o:Dynamic = {};
		var copy:Obj = Obj.fromDynamic( o );
		for (k in keys())
			copy.set(k, get(k));
		return copy;
	}

	/**
	  * Copy [this] Obj
	  */
	public function clone():Obj {
		var klass:Null<Class<Dynamic>> = Type.getClass( o );
		if (klass != null) {
			var copi:Dynamic = Type.createEmptyInstance(cast klass);
			var ocopy:Obj = copi;
			for (k in keys()) {
				ocopy[k] = get(k);
			}
			return ocopy;
		}
		else {
			return R.copy(o);
		}
	}

	/**
	  * add a JavaScript 'getter' method to [o]
	  */
	public inline function defineGetter<T>(key:String, getter:Getter<T>):Void {
		#if js
		call('__defineGetter__', untyped [key, getter]);
		#else
		set(key, getter.get());
		#end
	}

	/**
	  * add a JavaScript 'setter' method to [o]
	  */
	public inline function defineSetter<T>(key:String, setter:Setter<T>):Void {
		#if js
		call('__defineSetter__', untyped [key, setter]);
		#end
	}

	/**
	  * add a pointer as a property to [o]
	  */
	public inline function defineProperty<T>(name:String, pointer:Ptr<T>):Void {
		defineGetter(name, pointer.getter);
		defineSetter(name, pointer.setter);
	}

/* === Instance Field === */

	@:allow(tannus.ds.Obj)
	private var o : Dynamic;
	private var refCache : Map<String, Ptr<Dynamic>>;

/* === Class Methods === */

	public static function create(o : Dynamic):CObj {
		if (Std.is(o, CObj))
			return cast o;
		else
			return new CObj( o );
	}
}
