package tannus.dom;

import tannus.dom.Element;
import js.html.Element in JElem;

class ElIter {
	/* Constructor Function */
	public function new(e : Element):Void {
		owner = e;
		index = 0;
	}

/* === Instance Methods === */

	/* whether there is a next item */
	public function hasNext():Bool {
		return (index < owner.length);
	}

	/* get the next item */
	public function next():Element {
		return owner.at(index++);
	}

/* === Instance Fields === */

	private var owner : Element;
	private var index : Int;
}
