package tannus.ds.set;

import tannus.ds.*;
import tannus.io.*;

using Lambda;
using tannus.ds.ArrayTools;

class EnumValueSet<T:EnumValue> extends SetImpl<T> {
    public function new():Void {
        super(new Dict());
    }
}
