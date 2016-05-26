package tannus.utils;

@:forward
abstract Error (ErrorImpl) from ErrorImpl to ErrorImpl {
	/* Constructor Function */
	public inline function new(message:String):Void {
		this = new ErrorImpl( message );	
	}

	@:to
	public inline function toString():String {
		return Std.string( this );
	}
}
