package tannus.internal;

import tannus.internal.Target;
import tannus.internal.BuildFlag in Flag;
import tannus.internal.BuildComponent in Comp;
import tannus.sys.Path;

class BuildData {
	/* Constructor Function */
	public function new():Void {
		defs = new Array();
		classPaths = new Array();
		libraries = new Array();
	}

/* === Instance Methods === */

	/**
	  * Read build-data from a BuildFile AST
	  */
	public function parse(ast : Array<Comp>):Void {
		for (e in ast) {
			switch (e) {
				case Comp.BCMain(mc):
					mainClass = mc;

				case Comp.BCDef(defname):
					defs.push( defname );

				case Comp.BCClassPath(cp):
					classPaths.push( cp );

				case Comp.BCLib(ln, _):
					libraries.push( ln );

				case Comp.BCTarget(t, d):
					target = t;
					buildPath = new Path(d);

				case BCDebug:
					defs.push( 'debug' );

				default:
					var err:String = 'Unrecognized component $e';
					trace( err );
					throw err;
			}
		}
	}

/* === Instance Fields === */

	public var mainClass : Null<String> = null;
	public var defs : Array<String>;
	public var classPaths : Array<Path>;
	public var libraries : Array<String>;
	public var target : Null<Target> = null;
	public var buildPath : Null<Path> = null;
}
