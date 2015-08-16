package tannus.concurrent;

import tannus.ds.Object;
import tannus.concurrent.IProfess;

interface IWorker extends IProfess {
	function process(data : Object):Void;
}
