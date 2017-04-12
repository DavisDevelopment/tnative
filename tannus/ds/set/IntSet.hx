package tannus.ds.set;

import tannus.ds.*;
import tannus.io.*;

using Lambda;
using tannus.ds.ArrayTools;

class IntSet extends SetImpl<Int> {
    public function new()
        super(new Dict());
}
