package tannus.internal;

#if js
	import js.Error in Err;
#end

@:forward(message)
abstract Error (Err) from Err {
	/* Constructor Function */
	public inline function new(msg : String):Void {
		this = new Err( msg );
	}

	@:from
	public static inline function fromString(s : String) {
		return new Error( s );
	}
}

#if !js
	class Err {
		/* Constructor Function */
		public function new(msg : String):Void {
			message = msg;
		}

		public var message : String;
	}
#end
