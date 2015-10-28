package tannus.display;

import tannus.display.Stage;
import tannus.display.Entity;

import tannus.io.Getter;
import tannus.nore.Selector;
import tannus.ds.TwoTuple;


abstract StageSelection (TwoTuple<Selector<Entity>, Stage>) {
	/* Constructor Function */
	public inline function new(d:String, s:Stage):Void {
		this = new TwoTuple(new Selector(d), s);
	}

/* === Instance Methods === */

	/* DO Stuff */
	@:arrayAccess
	public inline function getEnt<T : Entity>(i : Int):Null<T> {
		return (cast matches[i]);
	}

	/**
	  * Iterate over all matches
	  */
	public inline function iterator():Iterator<Entity> {
		return (matches.iterator());
	}

	/**
	  * Delete all matched items
	  */

/* === Instance Fields === */

	/**
	  * Reference to the selector itself
	  */
	public var sel(get, never):Selector<Entity>;
	private inline function get_sel() return this.one;

	/**
	  * Reference to all matched Entity's on the Stage
	  */
	public var matches(get, never):Array<Entity>;
	private function get_matches():Array<Entity> {
		return this.two.childNodes.filter(sel.func.bind(_));
	}
}
