package tannus.nw;

import tannus.sys.Application;
import tannus.html.Win;

class NodeWebkit {
	/**
	  * Determine whether we're running in a node-webkit environment
	  */
	public static function isNodeWebkit():Bool {
		var require = getRequire();
		if (require == null) {
			return false;
		}
		else {
			try {
				var _gui:Null<Dynamic> = require( 'nw.gui' );
				if (_gui == null) {
					return false;
				}
				else {
					var gui:tannus.ds.Obj = _gui;
					var reqs = ['App', 'Clipboard', 'Window'];
					for (n in reqs) {
						if (!gui.exists( n )) {
							return false;
						}
					}
				}
			}
			catch (err : Dynamic) {
				trace( err );
				return false;
			}
		}
		return true;
	}

	private static function getRequire():Null<String -> Dynamic> {
		if (untyped __js__('typeof require == "function"')) {
			return (untyped __js__('require'));
		}
		else {
			return null;
		}
	}
}
