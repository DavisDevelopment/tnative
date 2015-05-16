package tannus.internal;

import tannus.io.ByteArray;
import tannus.sys.Path;

import tannus.internal.BuildComponent;
import tannus.internal.BuildFlag;

/**
  * Object-Representation of the build-process of a Haxe Application
  */
class BuildFile {
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
	public function cp(path : Path)
		add(BCClassPath( path ));

	/**
	  * Add a 'lib' declaration
	  */
	public function lib(name:String, ?version:String)
		add(BCLib(name, version));

	/**
	  * Add a '-D' declaration
	  */
	public function def(name : String)
		add(BCDef( name ));

	public function defs(names : Array<String>)
		for (name in names)
			def( name );

	/**
	  * Add a macro call
	  */
	public function macroCall(code : String)
		add(BCMacro( code ));

	/**
	  * Add a '--next' flag
	  */
	public function next()
		add(BCNext);
	
	/**
	  * Place debug data into the code
	  */
	public function debug() 
		add(BCDebug);

	/**
	  * Output [this] Object as the code generated from it
	  */
	public function toHxml():ByteArray {
		return (new tannus.format.hxml.Writer().generate(this));
	}

/* === Instance Fields === */

	/* Array of BuildOperationComponents */
	public var comps : Array<BuildComponent>;
}
