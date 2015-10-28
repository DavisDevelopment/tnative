package tannus.ds.promises;

import tannus.ds.Promise;

class BoolPromise extends Promise<Bool> {
/* === Instance Methods === */

	/**
	  * Execute [cb] if [this]'s value is 'true'
	  */
	public function yep(onyes : Void->Void):BoolPromise {
		then(function(v) if (v) onyes());
		return this;
	}

	/**
	  * Execute [cb] if [this]'s value is 'false'
	  */
	public function nope(onno : Void->Void):BoolPromise {
		then(function(v) if (!v) onno());
		return this;
	}
}
