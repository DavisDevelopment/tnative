package tannus.async;

@:callable
abstract VoidAsync (VoidCb->Void) from VoidCb->Void to VoidCb->Void {
    public inline function new(f : VoidCb->Void)
        this = f;

    public function promise():VoidPromise {
        return new VoidPromise(function(yes, no) {
            this(function(?error) {
                if (error != null) {
                    no( error );
                }
                else {
                    yes();
                }
            });
        });
    }
}
