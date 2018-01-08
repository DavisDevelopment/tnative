package tannus.async;

@:callable
@:forward
abstract Callback<Result, Error> (?Error->?Result->Void) from ?Error->?Result->Void {
    public inline function new(f : ?Error->?Result->Void):Void {
        this = f;
    }

    public inline function wrap(body:Callback<Result,Error>->?Error->?Result->Void):Callback<Result,Error> {
        return new Callback(body.bind(this, _, _));
    }

    @:to
    public inline function raise():Error->Void return untyped this.bind(_, null);
    @:to
    public inline function yield():Result->Void return untyped this.bind(null, _);
    public inline function void(?val:Result, ?err:Error):Void->Void return this.bind(err, val);
    @:to
    public inline function toVoid():Void->Void return void();
}
