package tannus.concurrent;

interface IWorker<I, O> {
	function process(data:I, done:O->Void):Void;
}
