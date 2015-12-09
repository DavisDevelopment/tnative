package tannus.mvc;

import tannus.ds.Destructible;

interface Asset extends Destructible {
	function detach():Void;
}
