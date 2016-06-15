package tannus.ds;

@:callable
abstract Async (TAsync0) from TAsync0 to TAsync0 {
	/* Constructor Function */
	public inline function new(f : TAsync0):Void {
		this = f;
	}

	/* === Type Casting Methods === */

	/* from Task */
	@:from
	public static inline function fromTask(t : Task):Async {
		return new Async(t.toAsync());
	}

	/* to Task */
	@:to
	public inline function toTask():Task {
		return new AsyncTask(cast this);
	}
}

@:callable
abstract Async1<T> (TAsync1<T>) from TAsync1<T> to TAsync1<T> {
	/* Constructor Function */
	public inline function new(f : TAsync1<T>):Void {
		this = f;
	}
}

private class AsyncTask extends Task {
    public function new(a : Async):Void {
        super();
        f = a;
    }
    
    override public function action(done : Void->Void):Void {
        f( done );
    }
    
    private var f : Async;
}

private typedef TAsync0 = AsyncComplete0 -> Void;
private typedef TAsync1<T> = Int -> AsyncComplete1<T> -> Void;

private typedef AsyncComplete0 = Void -> Void;
private typedef AsyncComplete1<T> = Null<Dynamic> -> Null<T> -> Void;
