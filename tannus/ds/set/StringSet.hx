package tannus.ds.set;

import tannus.ds.*;
import tannus.io.*;

using Lambda;
using tannus.ds.ArrayTools;

class StringSet extends SetImpl<String> {
    public function new()
        super(new Dict());
}
