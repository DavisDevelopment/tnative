package tannus.dom;

import js.html.Element in JElement;
import js.Browser.document;
import js.html.DOMParser;

import tannus.geom.*;
import tannus.ds.Object;
import tannus.ds.Obj;

import Std.*;
import Std.is in type;

using StringTools;
using tannus.ds.StringUtils;
using Lambda;
using tannus.ds.ArrayTools;

@:forward
abstract Element (CElement) from CElement to CElement {
	/* Constructor Function */
	public inline function new(ctx : Dynamic):Void {
		this = new CElement( ctx );
	}

/* === Instance Methods === */

	@:arrayAccess
	public inline function getAttribute(k:String):String return this.getAttribute(k);
	@:arrayAccess
	public inline function setAttribute(k:String, v:Dynamic):String return this.setAttribute(k, v);

	@:from
	public static inline function fromAny(o : Dynamic):Element {
		return new Element( o );
	}
}

class CElement {
	/* Constructor Function */
	public function new(ctx : Dynamic):Void {
		els = new Array();
		_style = new Styles( this );
		_attr = new Attributes( this );
		_data = new Data( this );

		determineContext( ctx );
		initializeData();
	}

/* === Public Methods === */

	/**
	  * Delete [this] Element
	  */
	public function remove():Void {
		for (e in els) {
			e.remove();
		}
	}

	/**
	  * Clone [this] Element
	  */
	public function clone(deep:Bool=false):Element {
		var copy = new Element(null);
		copy.els = els.macmap(cast _.cloneNode(deep));
		return copy;
	}

	/**
	  * Get a subset of [this] Selection
	  */
	public function find(sel : String):Element {
		var res:Element = new Element( null );
		for (e in els) {
			var nl = e.querySelectorAll( sel );
			for (i in 0...nl.length) {
				var item = nl.item( i );
				if (type(item, JElement)) {
					res.els.push(cast item);
				}
			}
		}
		return res;
	}

	/**
	  * get only the [n]th item of [this], as an Element
	  */
	public inline function at(n : Int):Element {
		return new Element(els[n]);
	}

	/**
	  * check if [this] Selection is a parent of any Element that would match [sel]
	  */
	public function contains(sel : String):Bool {
		var sub = find( sel );
		return !sub.empty;
	}

	/**
	  * Test [this] Element against the given CSS-Selector
	  */
	public function is(sel : String):Bool {
		return first.matches( sel );
	}

	/**
	  * Get the children of the current selection
	  */
	public function children():Element {
		var rels = els.macmap([for (i in 0..._.children.length) cast _.children.item(i)]).flatten();
		var res = new Element(null);
		res.els = rels;
		return res;
	}

	/**
	  * Check whether [this] Element is a descendent of [mparent]
	  */
	public function isParentOf(mchild : Element):Bool {
		if (!empty && !mchild.empty) {
			var node:Null<js.html.Node> = mchild.first.parentNode;
			while (node != null) {
				if (node == first) {
					return true;
				}
				node = node.parentNode;
			}
			return false;
		}
		else {
			return false;
		}
	}

	/**
	  * Check whether [this] Element is a child of [mparent]
	  */
	public function isDescendantOf(mparent : Element):Bool {
		return mparent.isParentOf( this );
	}

	/**
	  * Append [child] to [this] Element
	  */
	public function append(child : Element):Void {
		if ( !empty ) {
			for (e in child.els) {
				first.appendChild( e );
			}
		}
	}

	/**
	  * Append [this] Element to another
	  */
	public function appendTo(par : Element):Void {
		par.append( this );
	}

	/**
	  * Prepend [child] to [this]
	  */
	public function prepend(child : Element):Void {
		if ( !empty ) {
			for (e in child.els) {
				first.insertBefore(e, first.firstElementChild);
			}
		}
	}

	/**
	  * Prepend [this] to [parent]
	  */
	public function prependTo(par : Element):Void {
		par.prepend( this );
	}

	/**
	  * Add an Element to [this] Selection
	  */
	public function add(item : Element):Void {
		els = els.concat( item.els );
	}

	/**
	  * insert an element after the given element
	  */
	public inline function insertAfter(child:Element, after:Element):Void {
		first.insertBefore(child.first, after.first.nextSibling);
	}

	/**
	  * Insert the given content after each selected Element
	  */
	public function after(content : Element):Void {
		for (e in els) {
			var cont = content.clone( true );
			for (c in cont.els) {
				e.parentElement.insertBefore(c, e.nextSibling);
			}
		}
	}

	/**
	  * Insert the given content before each selected Element
	  */
	public function before(content : Element):Void {
		for (e in els) {
			var cont = content.clone( true );
			for (c in cont.els) {
				e.parentElement.insertBefore(c, e);
			}
		}
	}

	/**
	  * replace the given child with the given Element
	  */
	public function replaceChild(child:Element, repl:Element):Void {
		if ( !empty ) {
			first.replaceChild(repl.first, child.first);
		}
	}

	/**
	  * replace [this] with the given Element
	  */
	public inline function replaceWith(other : Element):Void {
		parent.replaceChild(this, other);
	}

	/**
	  * Get the value of an attribute
	  */
	public function getAttribute(name : String):String {
		return attributes.get( name );
	}

	/**
	  * Set the value of an attribute
	  */
	public function setAttribute(name:String, value:Dynamic):String {
		return attributes.set(name, value);
	}

	/**
	  * Check for the existence of an attribute
	  */
	public function hasAttribute(name : String):Bool {
		return attributes.exists( name );
	}

	/**
	  * Remove an attribute
	  */
	public function removeAttribute(name : String):Void {
		attributes.remove( name );
	}

	/**
	  * Check for existence of a class
	  */
	public function hasClass(name : String):Bool {
		if ( !empty ) {
			return first.classList.contains( name );
		}
		else 
			return false;
	}

	/**
	  * Add a class to [this] Element
	  */
	public function addClass(name : String):Void {
		for (e in els) {
			if (!e.classList.contains(name))
				e.classList.add( name );
		}
	}

	/**
	  * Remove a class from [this] Element
	  */
	public function removeClass(name : String):Void {
		for (e in els) {
			e.classList.remove( name );
		}
	}

	/**
	  * Toggle a class
	  */
	public function toggleClass(name : String):Void {
		for (e in els) {
			e.classList.toggle( name );
		}
	}

	/**
	  * Access some field of [first]
	  */
	public function field<T>(name:String, ?value:T):Null<T> {
		if ( empty )
			return null;

		if (value == null) {
			return (untyped Reflect.getProperty(first, name));
		}
		else {
			Reflect.setProperty(first, name, value);
			return (untyped Reflect.getProperty(first, name));
		}
	}

	/**
	  * Listen for events on [this] Element
	  */
	public function on<T>(name:String, handler:T -> Void):Void {
		for (e in els) {
			var nd = nodeData( e );
			e.addEventListener(name, handler);
			if (!nd.pri.exists('events')) {
				nd.pri.set('events', Obj.fromDynamic({}));
			}
			var events:Obj = nd.pri['events'];
			if (!events.exists(name)) {
				events[name] = new Array();
			}
			events[name].push( handler );
		}
	}

	/**
	  * Stop listening for events on [this] Element
	  */
	public function off<T>(name:String, ?handler:T -> Void):Void {
		for (e in els) {
			if (handler != null) {
				e.removeEventListener(name, handler);
			}
			else {
				var nd = nodeData( e );
				if (!nd.pri.exists('events'))
					nd.pri.set('events', Obj.fromDynamic({}));
				var events:Obj = nd.pri['events'];
				if (events.exists(name)) {
					var handlers:Array<Dynamic->Void> = events[name];
					for (f in handlers) {
						e.removeEventListener(name, f);
					}
				}
			}
		}
	}

	/**
	  * Get the 'value' of [this] Element, if applicable
	  */
	public function value():Null<String> {
		switch ( tagname ) {
			case 'input':
				return field('value');

			default:
				return null;
		}
	}

	/**
	  * iterate over all selected items, as Element instances
	  */
	public function iterator():Iterator<Element> {
		return new ElIter( this );
	}

	/**
	  * the client-rectangle of [this] Element
	  */
	public function rect():Rectangle {
		if ( !empty ) {
			var cr = first.getBoundingClientRect();
			return new Rectangle(cr.x, cr.y, cr.width, cr.height);
		}
		else {
			return new Rectangle(0, 0, 0, 0);
		}
	}

/* === Internal Methods === */

	/**
	  * Determine the context
	  */
	private function determineContext(ctx : Dynamic):Void {
		if (ctx == null) {
			return ;
		}
		else if (type(ctx, String)) {
			determineStringContext(string( ctx ));
		}
		else if (type(ctx, JElement)) {
			els.push(cast ctx);
		}
		else if (type(ctx, CElement)) {
			var el:CElement = cast ctx;
			els = el.els;
		}
		else {
			throw 'DOMError: Invalid Element context';
		}
	}

	/**
	  * Determine the context from the given String
	  */
	private function determineStringContext(s : String):Void {
		s = s.trim();
		if (s.startsWith('<')) {
			els = parseDocument( s );
		}
		else {
			var nl = document.querySelectorAll( s );
			for (i in 0...nl.length) {
				var item = nl.item( i );
				if (type(item, JElement)) {
					els.push(cast item);
				}
			}
		}
	}

	/**
	  * Initialize the extra fields of JElement in use by this class
	  */
	private function initializeData():Void {
		for (el in els) {
			var e:Object = new Object( el );
			if (!e.exists( DATAKEY )) {
				e.set(DATAKEY, {
					'pri': Obj.fromDynamic({}),
					'pub': Obj.fromDynamic({})
				});
			}
		}
	}

	/**
	  * Get the NodeData for a given JElement
	  */
	@:allow( tannus.dom.Data.CData )
	private function nodeData(e : JElement):NodeData {
		return (untyped Reflect.getProperty(e, DATAKEY));
	}

/* === Computed Instance Fields === */

	/* the number of selected elements */
	public var length(get, never):Int;
	private inline function get_length():Int return els.length;

	/* whether nothing is currently selected */
	public var empty(get, never):Bool;
	private inline function get_empty():Bool {
		return (length <= 0);
	}

	/* whether [this] actually references any nodes */
	public var exists(get, never):Bool;
	private inline function get_exists():Bool {
		return !empty;
	}

	/* the first selected element */
	public var first(get, never):JElement;
	private inline function get_first():JElement {
		return els[0];
	}

	/* the css styles associated with [this] Element */
	public var css(get, never):Styles;
	private inline function get_css():Styles {
		return _style;
	}

	/* the attributes associated with [this] Element */
	public var attributes(get, never):Attributes;
	private inline function get_attributes():Attributes {
		return _attr;
	}

	/* the data associated with [this] Element */
	public var data(get, never):Data;
	private inline function get_data():Data {
		return _data;
	}

	/* [els] as Array<Element> */
	private var elements(get, never):Array<Element>;
	private function get_elements():Array<Element> {
		return els.macmap(new Element(_));
	}

	/* the HTML content of [this] Element */
	public var html(get, set):String;
	private function get_html():String {
		if ( !empty ) {
			return first.innerHTML;
		}
		else {
			return '';
		}
	}
	private function set_html(v : String):String {
		for (e in els) {
			e.innerHTML = v;
		}
		return v;
	}

	/* the textual content of [this] ELement */
	public var text(get, set):String;
	private function get_text():String {
		if ( exists ) {
			var result:String = '';
			for (e in els) {
				result += e.textContent;
			}
			return result;
		}
		else {
			return '';
		}
	}
	private function set_text(v : String):String {
		for (e in els) {
			e.textContent = v;
		}
		return v;
	}

	/* get the tagname of [this] element */
	public var tagname(get, never):String;
	private function get_tagname():String {
		return (empty ? '' : first.tagName.toLowerCase());
	}

	/* the parent of [this] element (if any) */
	public var parent(get, never):Null<Element>;
	private function get_parent():Null<Element> {
		if (!empty && (first.parentElement != null)) {
			return new Element( first.parentElement );
		}
		else {
			return null;
		}
	}

/* === Instance Fields === */

	public var els : Array<JElement>;
	private var _style : Styles;
	private var _attr : Attributes;
	private var _data : Data;

/* === Static Methods === */

	/**
	  * Get an Array of Elements from an HTML snippet
	  */
	public static function parseDocument(code : String):Array<JElement> {
		var parser = new DOMParser();
		var doc = parser.parseFromString(code, js.html.SupportedType.TEXT_HTML);
		var nl = doc.querySelectorAll('body *, head *');
		var results:Array<JElement> = new Array();
		for (i in 0...nl.length) {
			var item = nl.item( i );
			if (is(item, JElement)) {
				results.push(cast item);
			}
		}
		return results.unique();
	}

	private static inline var DATAKEY:String = '__tandata';
}

typedef NodeData = {
	var pri : Obj;
	var pub : Obj;
};
