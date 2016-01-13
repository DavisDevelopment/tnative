package tannus.xml;

import tannus.ds.Object;
import tannus.ds.Obj;

class Elem {
	/* Constructor Function */
	public function new(type:String, ?parent:Elem):Void {
		tag = type;
		text = '';
		attributes = {};
		children = new Array();

		if (parent != null) {
			parent.addChild( this );
		}
	}

/* === Instance Methods === */

	/* Append an Elem to [this] */
	public function addChild(child : Elem):Void {
		children.push( child );
		child.parent = this;
	}

	/* Remove an Elem from [this] */
	public function removeChild(child : Elem):Void {
		children.remove( child );
	}

	/* Insert an Elem onto [this] */
	public function insertChild(child:Elem, index:Int):Void {
		children.insert(index, child);
	}

	/* Replace one child with another */
	public function replaceChild(oldChild:Elem, newChild:Elem):Void {
		children[children.indexOf(oldChild)] = newChild;
	}

	/* Obtain the index of [child] in [this] */
	public function indexOfChild(child : Elem):Int {
		for (i in 0...children.length)
			if (children[i] == child)
				return i;
		return -1;

	}

	/**
	  * get the index of [this] element
	  */
	public function index():Int {
		if (parent != null)
			return parent.indexOfChild( this );
		else
			return -1;
	}

	/**
	  * replace [this] Element with the given one
	  */
	public function replaceWith(other : Elem):Void {
		if (parent != null) {
			parent.replaceChild(this, other);
		}
	}

	/**
	  * add the given element as a child of [this] one
	  */
	public inline function append(child : Elem):Void {
		addChild( child );
	}

	/**
	  * add the given element as a child of [this] one, before all the other children
	  */
	public function prepend(child : Elem):Void {
		addChild( child );
		children.remove( child );
		children.insert(0, child);
	}

	/**
	  * insert the [what] before [before]
	  */
	public function insertBefore(what:Elem, before:Elem):Void {
		addChild( what );
		children.remove( what );
		children.insert(indexOfChild(before), what);
	}

	/**
	  * insert [what] after [after]
	  */
	public function insertAfter(what:Elem, after:Elem):Void {
		addChild( what );
		children.remove( what );
		children.insert(indexOfChild(after) + 1, what);
	}

	/**
	  * insert what after [this]
	  */
	public function after(what : Elem):Void {
		if (parent != null) {
			parent.insertAfter(what, this);
		}
	}

	/**
	  * insert what before [this]
	  */
	public function before(what : Elem):Void {
		if (parent != null) {
			parent.insertBefore(what, this);
		}
	}

	/* Get the value of an attributesibute of [this] Elem */
	public function get(key : String):Null<String> {
		return attributes[key];
	}

	/* Set the value of an attributesibute */
	public function set(key:String, val:String):String {
		attributes.set(key, val);
		return get( key );
	}

	/* Check whether [this] has an attributesibute */
	public function exists(key : String):Bool {
		return attributes.exists(key);
	}

	/**
	  * batch-set attributes on [this] Elem
	  */
	public function attr(_batch : Dynamic):Elem {
		var batch:Obj = Obj.fromDynamic( _batch );
		for (key in batch.keys()) {
			set(key, Std.string(batch[key]));
		}
		return this;
	}

	/* Apply [f] recursively to all children of [this] */
	public function walk(f : Elem->Void):Void {
		if (parent != null)
			f(this);
		for (kid in children)
			f(kid);
	}

	/* Find all Elems for whom [test] returns true */
	public function query(test : Elem->Bool):Array<Elem> {
		var res:Array<Elem> = new Array();
		walk(function( el ) {
			if (test( el )) {
				res.push( el );
			}
		});
		return res;
	}

	/* find all children of [this] with a tag of [name] */
	public function find(name : String):Array<Elem> {
		var res = new Array();
		for (e in children)
			if (e.tag == name)
				res.push( e );
		return res;
	}

	/* Find all Elements with a [tag] of [name] */
	public function findByName(name : String):Array<Elem> {
		return query(function(e) return (e.tag.toLowerCase() == name.toLowerCase()));
	}

	/* Find all Elems whose [key] attributesibute equals [val] */
	public function findByAttribute(key:String, val:String):Array<Elem> {
		return query(function(e) {
			return (e.attributes[key] == val);
		});
	}

	/* Convert [this] Elem to Xml */
	public function toXml():Xml {
		var xm = Xml.createElement( tag );
		if (text != '') {
			xm.addChild(Xml.createPCData(text));
		}

		for (k in attributes.keys) {
			xm.set(k, get(k));
		}

		for (child in children) {
			xm.addChild(child.toXml());
		}

		return xm;
	}

	/**
	  * Output [this] DOM as an XML String
	  */
	public function print(pretty:Bool = false):String {
		return tannus.xml.Printer.print(this, pretty);
	}

	/**
	  * method called just before [this] Node is stringified
	  */
	private function _pre_print():Void {
		null;
	}

/* === Static Fields === */

	/* Create a new Elem */
	public static inline function create(t : String) return new Elem(t);

	/* Create an Elem from an Xml */
	public static function fromXml(x : Xml):Elem {
		var el:Elem = new Elem(x.nodeName);
		try {
			el.text = x.firstChild().nodeValue;
		} catch (err : String) {}

		for (k in x.attributes()) {
			el.set(k, x.get(k));
		}

		for (e in x.elements()) {
			el.addChild(fromXml(e));
		}
		
		return el;
	}

	public static function parse(code : String):Elem {
		return fromXml(Xml.parse(code).firstChild());
	}

/* === Instance Fields === */

	//- The tag-type of [this] Element
	public var tag:String;

	//- The text value of [this] Elem
	public var text:String;

	//- Attributes associated with [this] Elem
	public var attributes:Object;

	//- Array of Elems which are children to [this]
	public var children:Array<Elem>;

	//- The 'parent' Elem of [this] Elem
	public var parent:Null<Elem>;
}
