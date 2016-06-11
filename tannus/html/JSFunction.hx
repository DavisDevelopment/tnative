package tannus.html;

import tannus.ds.Obj;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.extern.*;

using haxe.macro.ExprTools;
using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;

abstract JSFunction (Dynamic) from Dynamic to Dynamic {
	/* Constructor Function */
	public inline function new(f : Dynamic):Void {
		this = f;
	}

/* === Instance Methods === */

	/**
	  * Call [this] Function with [o] as 'this'
	  */
	public inline function apply(o:Dynamic, args:Array<Dynamic>):Dynamic return this.apply(o, args);

	/**
	  * Bind [this] Function to use [o] as the value of 'this'
	  */
	public inline function bind(thisValue : Dynamic):JSFunction {
		return this.bind( thisValue );
	}

/* === Instance Fields === */

	public var prototype(get, set):Dynamic;
	private inline function get_prototype():Dynamic return this.prototype;
	private inline function set_prototype(v : Dynamic):Dynamic return (this.prototype = v);
}
