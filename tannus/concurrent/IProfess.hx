package tannus.concurrent;

import tannus.ds.Object;

interface IProfess {
	function send(data : Object):Void;
	function onMessage(cb : Object->Void):Void;
}
