package tannus.ds;

@:callable
abstract Async (TAsync) from TAsync to TAsync {
    /* Constructor Function */
    public inline function new(f : TAsync):Void {
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

private typedef TAsync = AsyncComplete -> Void;
private typedef AsyncComplete = Void -> Void;