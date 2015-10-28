package tannus.sys;

import tannus.io.ByteArray;
import tannus.io.Signal;
import tannus.ds.Object;
import tannus.sys.Path;

interface IProcess {
/* === Fields === */

	/* Signal fired when the Process is complete */
	var complete : Signal<Dynamic>;

	/* ByteArray to hold the output of [this] Process */
	var output : ByteArray;

	var input : ByteArray;

	var env : Map<String, String>;

	var cwd : Path;

	var pid : Int;

/* === Methods === */

	/* Wait for [this] Process to complete */
	function await(cb : Void->Void):Void;
}
