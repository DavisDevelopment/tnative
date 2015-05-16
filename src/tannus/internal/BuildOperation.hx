package tannus.internal;

import tannus.sys.Path;
import tannus.internal.BuildComponent;
import tannus.internal.BuildFlag;

class BuildOperation {
	/* Constructor Function */
	public function new():Void {
		comps = new Array();
	}

/* === Instance Methods === */

	/**
	  * Add a new BuildComponent to our Stack
	  */
	private inline function add(c : BuildComponent) comps.push(c);

	/**
	  * Set 'main' Class for [this] Build
	  */
	public function main(mc : String):Void
		add(BCMain( mc ));

	/**
	  * Build with a given target to a given dest
	  */
	public function target(t:String, dest:String)
		add(BCTarget(t, dest));

	/**
	  * Adds a Path to the class-path
	  */
	//public function cp(

/* === Instance Fields === */

	/* Array of BuildOperationComponents */
	private var comps : Array<
}
