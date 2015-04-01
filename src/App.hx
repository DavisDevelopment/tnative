package ;

import tnative.io.Ptr;
import tnative.sys.Path;
import tnative.TSys;

private typedef F = tnative.sys.FileSystem;

class App {
	/* Main entry point of the program */
	public static function main():Void {
		var penis = TSys.getEnv('FUCK');

		trace(penis);
	}
}
