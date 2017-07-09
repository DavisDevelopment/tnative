package tannus.async;

@:forward
@:callable
abstract Cb<T> (Callback<T, Dynamic>) from Callback<T, Dynamic> {
    public inline function new(f : Callback<T,Dynamic>) {
        this = f;
    }

    @:to
    public inline function raise():Dynamic->Void return this.raise();
    @:to
    public inline function yield():T->Void return this.yield();
    @:to
    public inline function toVoid():Void->Void return this.toVoid();
}

