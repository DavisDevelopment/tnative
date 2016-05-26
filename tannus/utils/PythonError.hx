package tannus.utils;

import python.Exceptions.Exception;

class PythonError extends Exception {
	public function new(message : String):Void {
		super( message );
	}
}
