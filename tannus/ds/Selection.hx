package tannus.ds;

import Std.*;
import Math.*;
import tannus.math.TMath.*;

using Lambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;

class Selection<T : Selectable> {
	/* Constructor Function */
	public function new(?list : Array<T>):Void {
		data = (list != null ? list : new Array());
	}

/* === Instance Methods === */

	/**
	  * Add an item
	  */
	public function addItem(i : T):Void {
		if (!data.has( i )) {
			data.push( i );
		}
	}

	/**
	  * Remove an Item
	  */
	public function removeItem(i : T):Bool {
		return data.remove( i );
	}

	/**
	  * Get the selected items
	  */
	public function selected():Array<T> {
		return data.macfilter(_.getSelected());
	}

	/**
	  * Select the given item
	  */
	public inline function select(item : T):Void {
		item.setSelected( true );
	}

	/**
	  * Deselect the given item
	  */
	public inline function deselect(item : T):Void {
		item.setSelected( false );
	}

	/**
	  * Toggle the given item
	  */
	public inline function toggle(item : T):Void {
		item.setSelected(!item.getSelected());
	}

	/**
	  * Iterate over the selected items
	  */
	public function iterator():Iterator<T> {
		return selected().iterator();
	}

/* === Instance Fields === */

	private var data : Array<T>;
}
