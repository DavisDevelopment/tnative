package tannus.concurrent;

interface IBoss<I, O> {
	function send(data:I, ?onreply:O->Void):Void;
}
