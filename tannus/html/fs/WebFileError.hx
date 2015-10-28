package tannus.html.fs;

class WebFileError extends Error {
	/* Constructor Function */
	public function new(type:ErrorCode, msg:String):Void {
		super( msg );
		name = 'FileSystemError';
		code = type;
	}

/* === Instance Fields === */
	public var code : ErrorCode;
}

@:native('Error')
extern class Error {
	function new(msg : String):Void;

	public var name : String;
	public var message : String;
}

@:enum
abstract ErrorCode (Int) from Int {
	var Abort = 3;
	var Encoding = 5;
	var InvalidModification = 9;
	var InvalidState = 7;
	var NotFound = 1;
	var NotReadable = 4;
	var NoModification = 6;
	var PathExists = 12;
	var QuotaExceded = 10;
	var TypeMismatch = 11;
}
