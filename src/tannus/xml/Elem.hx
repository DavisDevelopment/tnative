package tannus.xml;

class Elem {
	/* Constructor Function */
	public function new(type:String, ?parent:Elem):Void {
		tag = type;
		text = '';
		attr = new Map();
		children = new Array();

		if (parent != null) {
			parent.addChild( this );
		}
	}

/* === Instance Methods === */

	/* Append an Elem to [this] */
	public function addChild(child : Elem):Void {
		children.push( child );
		child.parent = child;
	}

	/* Remove an Elem from [this] */
	public function removeChild(child : Elem):Void {
		children.remove( child );
	}

	/* Insert an Elem onto [this] */
	public function insertChild(child:Elem, index:Int):Void {
		children.insert(index, child);
	}

	/* Obtain the index of [child] in [this] */
	public function indexOfChild(child : Elem):Int {
		return children.indexOf(child);
	}

	/* Get the value of an attribute of [this] Elem */
	public function get(key : String):Null<String> {
		return attr[key];
	}

	/* Set the value of an attribute */
	public function set(key:String, val:String):Void {
		attr.set(key, val);
	}

	/* Check whether [this] has an attribute */
	public function exists(key : String):Bool {
		return attr.exists(key);
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

	/* Find all Elements with a [tag] of [name] */
	public function findByName(name : String):Array<Elem> {
		return query(function(e) return (e.tag == name));
	}

	/* Find all Elems whose [key] attribute equals [val] */
	public function findByAttribute(key:String, val:String):Array<Elem> {
		return query(function(e) {
			return (e.attr[key] == val);
		});
	}

	/* Convert [this] Elem to Xml */
	public function toXml():Xml {
		var xm = Xml.createElement( tag );
		if (text != '') {
			xm.addChild(Xml.createPCData(text));
		}

		for (k in attr.keys()) {
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
	public function print(?pretty:Bool=false):String {
		return haxe.xml.Printer.print(toXml(), pretty);
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
	public var attr:Map<String, String>;

	//- Array of Elems which are children to [this]
	public var children:Array<Elem>;

	//- The 'parent' Elem of [this] Elem
	public var parent:Null<Elem>;
}
