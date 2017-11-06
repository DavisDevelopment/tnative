package tannus.async;

import tannus.io.VoidSignal;

class OnceSignal {
    /* Constructor Function */
    public function new():Void {
        status = false;
        signal = new VoidSignal();

        signal.once(function() {
            status = true;
        });
    }

/* === Instance Methods === */

    public inline function isReady():Bool return status;
    public inline function announce():Void return signal.fire();
    
    public function on(action : Void->Void):Void {
        if (isReady()) {
            action();
        }
        else {
            signal.once( action );
        }
    }

/* === Instance Fields === */

    private var status : Bool;
    private var signal : VoidSignal;
}
