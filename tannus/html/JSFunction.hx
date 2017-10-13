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

@:callable
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

	public inline function toString():String return this.toString();
	public inline function toSource():String return this.toSource();

/* === Instance Fields === */

	public var prototype(get, set):Dynamic;
	private inline function get_prototype():Dynamic return this.prototype;
	private inline function set_prototype(v : Dynamic):Dynamic return (this.prototype = v);

	public var length(get, never):Int;
	private inline function get_length() return this.length;

	public var name(get, never):String;
	private inline function get_name() return this.name;
}
