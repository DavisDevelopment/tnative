package tannus.io;

import tannus.io.Getter;
import tannus.io.Setter;
import tannus.ds.Object;

import haxe.macro.Expr;

@:generic
abstract Pointer<T> (Ptr<T>) from Ptr<T> {
	/* Constructor Function */
	public inline function new(g:Getter<T>, s:Setter<T>):Void {
		this = new Ptr(g, s);
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
		return get();
	}
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
	private inline function get_getter() return this.getter;
	private inline function set_getter(ng) return (this.getter = ng);

	/**
	  * The Setter for [this] Pointer
	  */
	public var setter(get, set):Setter<T>;
	private inline function get_setter() return this.setter;
	private inline function set_setter(ns) return (this.setter = ns);

	/**
	  * Alias to 'value'
	  */
	public var _(get, set):T;
	private inline function get__() return value;
	private inline function set__(v) return (value = v);

/* === Instance Methods === */

	/**
	  * Get [this]'s value
	  */
	@:to
	public inline function get():T {
		return this.get();
	}

	/**
	  * Set [this]'s value
	  */
	@:op(A &= B)
	public inline function set(v : T):T {
		return this.set( v );
	}

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
	public function access(?v : T):T {
		return this.access( v );
	}

	/**
	  * Attach a Setter to [this] Pointer
	  */
	@:op(A += B)
	public function attach_str(str : Setter<T>):Void {
		setter.attach( str );
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
	  * Obtain a Pointer to a field of the object referenced by [this] Pointer
	  */
	public function field<F>(key : String):Pointer<F> {
		var o = toObjectPointer();
		return cast (new Pointer((function() return (o.get()[key])), (function(v) return ((o.get())[key] = v))));
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
	  * Create a Pointer to the value of [this] Pointer, as an Object
	  */
	@:to
	public inline function toObjectPointer():Pointer<Object> {
		return cast this;
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
	public macro function create<T>(val : ExprOf<T>):ExprOf<Pointer<T>> {
		return macro new tannus.io.Pointer(tannus.io.Getter.create($val), tannus.io.Setter.create($val));
	}

	public macro function dual<T>(gref:ExprOf<T>, sref:ExprOf<T>):ExprOf<Pointer<T>> {
		return macro new tannus.io.Pointer(tannus.io.Getter.create($gref), tannus.io.Setter.create($sref));
	}
}

@:generic
private class Ptr<T> {
	/* Constructor Function */
	public inline function new(get:Getter<T>, set:Setter<T>):Void {
		getter = get;
		setter = set;
	}

/* === Instance Methods === */

	/**
	  * Get the value referenced by [this] Pointer
	  */
	public inline function get():T {
		return getter();
	}

	/**
	  * Set the value referenced by [this] Pointer
	  */
	public inline function set(value : T):T {
		return setter( value );
	}

	/**
	  * JQuery-style access-function
	  */
	public function access(?nv : T):T {
		if (nv != null) {
			return set( nv );
		} else {
			return get();
		}
	}

/* === Computed Instance Fields === */

	/**
	  * The value referenced by [this] Pointer
	  */
	public var value(get, set):T;
	private inline function get_value():T {
		return get();
	}
	private inline function set_value(nv : T):T {
		return set( nv );
	}

/* === Instance Fields === */

	/* The getter for [this] Pointer */
	public var getter : Getter<T>;

	/* The setter for [this] Pointer */
	public var setter : Setter<T>;
}
