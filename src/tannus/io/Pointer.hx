package tannus.io;

import tannus.io.Getter;
import tannus.io.Setter;
import tannus.ds.Destructible;

import tannus.ds.tuples.Tup2;
// import tannus.ds.Object;

import haxe.macro.Expr;

@:generic
abstract Pointer<T> (Ref<T>) from Ref<T> {
	/* Constructor Function */
	public inline function new(g:Getter<T>, s:Setter<T>, ?d:Void->Void):Void {
		//this = new Ref(g, s);
		this = {
			'get': g,
			'set': s,
			'delete': d
		};
	}

/* === Instance Fields === */

	/**
	  * internal reference to [this] as a Pointer
	  */
	private var self(get, never):Pointer<T>;
	private inline function get_self():Pointer<T> {
		return this;
	}

	/**
	  * The value referenced by [this] Pointer, as a field
	  */
	public var value(get, set):T;
	private inline function get_value():T {
		return get(); }
	private inline function set_value(nv : T):T {
		return set( nv );
	}

	/**
	  * Shorter alias to 'value'
	  */
	public var v(get, set):T;
	private inline function get_v() return value;
	private inline function set_v(nv) return (value = nv);

	/**
	  * The Getter for [this] Pointer
	  */
	public var getter(get, set):Getter<T>;
	private inline function get_getter() return this.get;
	private inline function set_getter(ng) return (this.get = ng);

	/**
	  * The Setter for [this] Pointer
	  */
	public var setter(get, set):Setter<T>;
	private inline function get_setter() return this.set;
	private inline function set_setter(ns) return (this.set = ns);

	/**
	  * Alias to 'value'
	  */
	public var _(get, set):T;
	private inline function get__() return value;
	private inline function set__(v) return (value = v);

/* === Instance Methods === */

	/**
	  * Function to 'get' the value of [this] Pointer
	  */
	public var get(get, never):Void->T;
	private inline function get_get() return cast getter;

	/**
	  * Function to 'set' the value of [this] Pointer
	  */
	public var set(get, never):T->T;
	private inline function get_set() return cast setter;

	/**
	  * Set the deleter function for [this] Pointer
	  */
	public inline function deleter(f : Void->Void):Void {
		this.delete = f;
	}

	/**
	  * Destroy [this] Pointer
	  */
	public inline function delete():Void {
		if (this.delete != null)
			this.delete();
	}

	/**
	  * Cast to [this] Pointer's underlying type implicitly
	  */
	@:to
	private inline function to_underlying():T return get();

	/**
	  * Set [this]'s value using the &= operator
	  */
	@:op(A &= B)
	private inline function setvalue(v : T):T return set( v );

	/**
	  * Set [this]'s value by a Pointer
	  */
	@:op(A &= B)
	public inline function setPointer(v : Pointer<T>):T {
		return set( v );
	}

	/**
	  * JQuery-style accessor function
	  */
	public inline function access(?v : T):T {
		return (v != null ? set(v) : get());
	}

	/**
	  * Attach a Setter to [this] Pointer
	  */
	@:op(A += B)
	public inline function attach_str(str : Setter<T>):Void {
		var s = setter;
		this.set = s.attach( str );
	}

	/**
	  * Attach a Setter, macro-style
	  */
	public macro function attach(self, other) {
		var setter = Setter.create(other);
		return macro $self.attach_str(function(v) return ($other = v));
	}

	/**
	  * Apply a transformation to [this] Pointer
	  */
	public function transform<O>(mget:T->O, mset:O->T):Pointer<O> {
		return new Pointer(getter.transform(mget), setter.transform(mset));
	}

	/**
	  * Create a clone of [this] Pointer
	  */
	public inline function clone():Pointer<T> {
		return new Pointer(getter, setter);
	}

	/**
	  * Convert [this] to a Getter
	  */
	@:to
	public inline function toGetter():Getter<T> {
		return getter;
	}

	/**
	  * Convert [this] to a Setter
	  */
	@:to
	public inline function toSetter():Setter<T> {
		return setter;
	}

	/**
	  * Convert [this] Pointer to a human-readable String
	  */
	@:to
	public function toString():String {
		return Std.string(get());
	}

	/**
	  * Return the iterator for Pointers which reference Iterable data
	  */
	public static function iterator<T>(self : Pointer<Iterable<T>>):Iterator<T> {
		return (self.v.iterator());
	}

/* === Class Methods === */

	/**
	  * Create and return a Pointer which references [val]
	  */
	public static macro function create<T>(val : ExprOf<T>):ExprOf<Pointer<T>> {
		return macro new tannus.io.Pointer(tannus.io.Getter.create($val), tannus.io.Setter.create($val));
	}

	/**
	  * Create and return a Pointer which references a variable with the value [val]
	  */
	public static macro function to<T>(val : ExprOf<T>):ExprOf<Pointer<T>> {
		return macro (function() {
			var _v = $val;
			return new tannus.io.Pointer(tannus.io.Getter.create(_v), tannus.io.Setter.create(_v));
		}());
	}

	public static macro function dual<T>(gref:ExprOf<T>, sref:ExprOf<T>):ExprOf<Pointer<T>> {
		return macro new tannus.io.Pointer(tannus.io.Getter.create($gref), tannus.io.Setter.create($sref));
	}

	/**
	  * Create a Pointer from a jQuery-style-accessor Function
	  */
	@:from
	public static function fromAccessor<T>(af : ?T->T):Pointer<T> {
		return new Pointer(af.bind(null), af.bind(_));
	}
}

// private typedef Ref<T> = Tup2<Getter<T>, Setter<T>>;
private typedef Ref<T> = {
	var get : Getter<T>;
	var set : Setter<T>;
	@:optional var delete : Void->Void;
};
