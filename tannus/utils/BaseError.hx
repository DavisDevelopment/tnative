package tannus.utils;

class BaseError {
	public function new(msg : String):Void {
		message = msg;
	}

	public function toString():String {
		return message;
	}

	public var message : String;
}
