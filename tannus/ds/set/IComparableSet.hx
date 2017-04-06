package tannus.ds.set;

import tannus.ds.*;
import tannus.io.*;

using Lambda;
using tannus.ds.ArrayTools;

class IComparableSet<T:IComparable<T>> extends SetImpl<T> {
    public function new() {
        super(new Dict());
    }
}
