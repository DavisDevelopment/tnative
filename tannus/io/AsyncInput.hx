package tannus.io;

/**
  * base-class for providing providing data to a 'reader' in chunks, rather than all at once
  */
@:allow( tannus.io.IOAccessor )
class AsyncInput<T> {
	/* Constructor Functoin */
	public function new():Void {
		__b = new Array();
		__eoi = false;

		opened = false;
		closed = false;
	}

/* === Instance Methods === */

	/**
	  * read a 'chunk' from [this] Stream
	  */
	public function read(provide:T->Void, ?reject:Err->Void):Void {
		if ( !opened ) {
			throw 'Error: ReadableStream must be opened (by calling the "open" method) before data can be read from it';
		}
		else if ( closed ) {
			throw 'Error: Cannot read from a closed Stream';
		}

		if (__b.length > 0) {
			provide(__b.shift());
		}
		else {
			if (reject == null) {
				reject = (function(err) throw err);
			}

			__get(
				function(chunk : Null<T>) {
					if (chunk == null) {
						var error = 'No data available on ReadableStream';
						reject( error );
					}
					else {
						provide( chunk );
					}
				},
				function(error : Err) {
					reject( error );
				}
			);
		}
	}

	/**
	  * must be defined by sub-classes
	  */
	private function __get(provide:Null<T>->Void, reject:Err->Void):Void {
		provide( null );
	}

	/**
	  * Read all available chunks
	  */
	public function readAll(?onchunk:T->Void, ?onerror:Err->Void, ?oncomplete:Void->Void):Void {
		if (onchunk == null)
			onchunk = (function(data) null);
		if (onerror == null)
			onerror = (function(error) throw error);
		if (oncomplete == null)
			oncomplete = (function() null);
		
		function step(data : T):Void {
			onchunk( data );

			if ( eoi ) {
				oncomplete();
			}
			else {
				read(step, onerror);
			}
		}

		read(step, onerror);
	}

	/**
	  * Open [this] Stream
	  */
	public function open(?cb : Void->Void):Void {
		opened = true;
	}

	/**
	  * Close [this] Stream
	  */
	public function close():Void {
		closed = true;
	}

	/**
	  * Forward all data to the given Output
	  */
	public function pipe(o : AsyncOutput<T>):Void {
		function onchunk(chunk : T) {
			o.write( chunk );
		}
		
		readAll( onchunk );
	}

	/**
	  * Write data to the Buffer
	  */
	private function buffer(d : T):Void {
		__b.push( d );
	}

	/**
	  * report that the end of input has been reached
	  */
	private function endOfInput():Void {
		__eoi = true;
	}

/* === Computed Instance Fields === */

	public var eoi(get, never):Bool;
	private inline function get_eoi():Bool return __eoi;

/* === Instance Fields === */

	private var __b : Array<T>;
	private var opened : Bool;
	private var closed : Bool;
	private var __eoi : Bool;
}

typedef Err = Dynamic;
