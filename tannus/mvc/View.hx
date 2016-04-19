package tannus.mvc;

import tannus.io.Signal;

class View<T> implements Asset {
	/* Constructor Function */
	public function new():Void {
		_target = null;
	}

/* === Instance Methods === */

	/**
	  * Build the rendering target
	  */
	private function build():Null<T> {
		return null;
	}

	/**
	  * Render [this] View
	  */
	public function render():Null<T> {
		if (_target != null) {
			throw 'Error: View already rendered!';
		}
		else {
			return (_target = build());
		}
	}

	/**
	  * Update [this] View
	  */
	public function update():Void {
		null;
	}

	/**
	  * Delete [this] View
	  */
	public function delete():Void {
		null;
	}

	/**
	  * Detach [this] View from a Model
	  */
	public function detach():Void {
		delete();
	}

/* === Instance Fields === */

	private var _target : Null<T>;
}
