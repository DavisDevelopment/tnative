package tannus.async;

interface Thenable <TResult, TChain> {
    function then(onResolved:TResult->Void, ?onRejected:Dynamic->Void):TChain;
}
