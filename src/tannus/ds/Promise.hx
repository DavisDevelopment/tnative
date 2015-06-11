package tannus.ds;

import tannus.io.Signal;

class Promise<T> {
	/* Constructor Function */
	public function new(exec:PromiseFunction<T>, ?nocall:Bool=false):Void {
		executor = exec;

		fulfillment = new Signal();
		rejection = new Signal();

		if (!nocall)
			executor(fulfill, reject);
	}

/* === Instance Methods === */

	/**
	  * Fulfill [this] Promise
	  */
	private function fulfill(v : T):Void {
		fulfillment.call( v );
	}

	/**
	  * Reject [this] Promise
	  */
	private function reject(err : Dynamic):Void {
		rejection.call( err );
	}

	/**
	  * Do something if [this] Promise is fulfilled
	  */
	public function then(callback : T->Void):Void {
		fulfillment.on( callback );
	}

	/**
	  * Do something if [this] Promise is rejected
	  */
	public function unless(callback : Dynamic->Void):Void {
		rejection.on( callback );
	}

/* === Instance Fields === */

	private var executor : PromiseFunction<T>;
	private var fulfillment : Signal<T>;
	private var rejection : Signal<Dynamic>;
}

private typedef PromiseFunction<T> = Fullfill<T> -> Reject<T> -> Void;
private typedef Fullfill<T> = T -> Void;
private typedef Reject<T> = Dynamic -> Void;
