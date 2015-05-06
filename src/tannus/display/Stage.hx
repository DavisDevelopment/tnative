package tannus.display;

import tannus.display.Window;
import tannus.display.TGraphics;
import tannus.display.Entity;
import tannus.graphics.GraphicsPath;

import tannus.geom.*;
import tannus.io.Ptr;

@:access(tannus.display.Entity)
class Stage {
	/* Constructor Function */
	public function new(w : Window):Void {
		window = w;
		childNodes = new Array();
		active = false;

		__init();
	}

/* === Instance Methods === */

	/**
	  * Perform any/all initialization of [this] Stage
	  */
	private function __init():Void {
		window.frameEvent.on(function(_x : Dynamic) {
			if (active) {
				frame();
			}
		});
	}

	/**
	  * Method which will fire every frame
	  */
	private function frame():Void {
		update();
		render();
	}

	/**
	  * Render all children of [this] Stage
	  */
	public function render():Void {
		var mg = window.graphics.createPath();
		var g:GraphicsPath;

		for (ent in childNodes) {
			g = mg.open();

			ent.__render( g );

			g.close();
		}

		mg.draw();
	}

	/**
	  * 'update' [this] Stage
	  */
	public function update():Void {
		for (ent in childNodes) {
			if (ent.__remove) {
				ent.__delete();
			}
		}

		haxe.ds.ArraySort.sort(childNodes, function(a, b) {
			return Std.int(a.z - b.z);
		});

		for (ent in childNodes) {
			ent.update();
		}
	}

	/**
	  * Mark [this] Stage as 'active'
	  */
	public function activate():Void {
		active = true;
	}

	/**
	  * Mark [this] Stage as 'inactive'
	  */
	public function deactivate():Void {
		active = false;
	}

	/**
	  * Add an Entity onto [this] Stage
	  */
	public function addChild(child : Entity):Void {
		childNodes.push( child );
		child.attachTo( this );
	}

	/**
	  * Remove an Entity from [this] Stage
	  */
	public function removeChild(child : Entity):Void {
		childNodes.remove( child );
	}

/* === Computed Instance Fields === */

	/**
	  * 'width' of [this] Stage
	  */
	public var width(get, set):Int;
	private inline function get_width() return Math.round(window.size.width);
	private inline function set_width(nw : Int) {
		window.size = new Area(nw, window.size.height);
		return nw;
	}

	/**
	  * 'height' of [this] Stage
	  */
	public var height(get, set):Int;
	private inline function get_height() return Math.round(window.size.height);
	private inline function set_height(nh : Int) {
		window.size = new Area(window.size.width, nh);
		return nh;
	}

/* === Instance Fields === */

	/* The Window [this] Stage is attached to */
	public var window : Window;

	/* An Array of Entities attached to [this] Stage */
	public var childNodes : Array<Entity>;

	/* Whether [this] Stage is Currently Active */
	private var active : Bool;

/* === Class Fields === */

	/* An Array of All Stage instances */
	private static var instances : Array<Stage> = {new Array();};
}
