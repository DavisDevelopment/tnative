package tannus.chrome;

import tannus.io.Ptr;
import tannus.io.Signal2 in Signal;
import tannus.ds.Memory;
import tannus.ds.Object;

import tannus.chrome.ContextMenu in Cm;
import tannus.chrome.MenuEntryType in EType;
import tannus.chrome.Tab;

class ContextMenuEntry {
	/* Constructor Function */
	public function new(txt:String=''):Void {
		id = Memory.uniqueIdString('ctx-');
		type = Normal;
		parent_id = null;
		title = txt;
		contexts = ['all'];
		patterns = new Array();
		click = new Signal();

		__init();
	}

/* === Instance Methods === */

	/**
	  * Initialize [this] Entry
	  */
	private inline function __init():Void {
		instances.push( this );
	}

	/**
	  * Append some Entry to [this] One
	  */
	public inline function append(child : ContextMenuEntry):Void {
		child.parent = this;
	}

	/**
	  * Append [this] Entry to another one
	  */
	public inline function appendTo(parent : ContextMenuEntry):Void {
		parent.append( this );
	}

	/**
	  * Add a URL Pattern to [this] Entry
	  */
	public inline function addPattern(pattern : String):Void {
		patterns.push( pattern );
	}

	/**
	  * 'Pack' [this] Entry into an actual ContextMenu
	  */
	public function pack():Void {
		Cm.create({
			'id' : id,
			'title' : title,
			'type' : type,
			'contexts' : contexts,
			'documentUrlPatterns' : patterns,
			'parentId' : parent_id,
			'onclick' : function(info:Object, tab:Tab) {
				click.call(info, tab);
			}
		});

		for (child in children)
			child.pack();
	}

/* === Computed Instance Fields === */

	/**
	  * The parent Entry of [this] One (If Any)
	  */
	public var parent(get, set):Null<ContextMenuEntry>;
	private inline function get_parent():Null<ContextMenuEntry> {
		if (parent_id != null) {
			return getEntry(parent_id);
		} else return null;
	}
	private inline function set_parent(np : Null<ContextMenuEntry>):Null<ContextMenuEntry> {
		if (np == null)
			parent_id = null;
		else
			parent_id = np.id;
		return parent;
	}

	/**
	  * All child-entries of [this] Entry
	  */
	public var children(get, never):Array<ContextMenuEntry>;
	private function get_children():Array<ContextMenuEntry> {
		return instances.filter(function(e) return e.parent_id == id);
	}

/* === Instance Fields === */
	
	/* The ID of [this] Entry */
	public var id : String;

	/* The 'type' of [this] Entry */
	public var type : EType;

	/* The ID of [this] Entry's parent */
	public var parent_id : Null<String>;

	/* The Title of [this] Entry */
	public var title : String;

	/* What to do when [this] Entry is Clicked */
	public var click : Signal<Object, Tab>;

	/* The contexts in which to display [this] Entry */
	public var contexts : Array<String>;

	/* URL-Patterns on which [this] Entry will display */
	public var patterns : Array<String>;

/* === Static Fields/Methods === */

	/* Array of all instances of [ContextMenuEntry] */
	public static var instances:Array<ContextMenuEntry> = {new Array();};

	/**
	  * Get the ContextMenuEntry instance with an ID of [id]
	  */
	public static function getEntry(id : String):Null<ContextMenuEntry> {
		for (e in instances)
			if (e.id == id)
				return e;
		return null;
	}
}
