package tannus.async;

@:callable
abstract VoidAsync (VoidCb->Void) from VoidCb->Void to VoidCb->Void {
    public inline function new(f : VoidCb->Void)
        this = f;
}