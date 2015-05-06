package tannus.display;

import tannus.io.Ptr;
import tannus.io.EventDispatcher;
import tannus.ds.Object;
import tannus.ds.Method;
import tannus.ds.Maybe;

import tannus.display.Stage;
import tannus.graphics.GraphicsPath;

import tannus.geom.*;

class Entity extends EventDispatcher {
	/* Constructor Function */
	public function new():Void {
		super();

		addSignal( 'delete' );
		addSignal( 'activate' );

		position = new Point();
		area = new Area();
		root = null;
		__remove = false;
		__cached = false;
	}

/* === Instance Methods === */

	/**
	  * Method called by Stage when [this] Entity is Attached to it
	  */
	private function attachTo(s : Stage):Void {
		root = s;
		dispatch('activate', s);
	}

	/**
	  * Method Called Internally When [this] Entity is Removed from the Stage
	  */
	private function __delete():Void {
		root.removeChild( this );
		dispatch('delete', this);
	}

	/**
	  * Method Called When [this] Entity is Removed from the Stage
	  */
	@:final
	public function delete():Void {
		__remove = true;
	}

	/**
	  * Method called internally upon rendering
	  */
	@:final
	private function __render(g : GraphicsPath):Void {
		render( g );
	}

	/**
	  * Method called each frame upon rendering
	  */
	public function render(g : GraphicsPath):Void {
		null;
	}

	/**
	  * Method called internally upon updating
	  */
	public function update():Void {
		null;
	}

	/**
	  * Cache [this] Entity
	  */
	public function cache():Void {
		__cached = true;
	}

	/**
	  * Uncache [this] Entity
	  */
	public function uncache():Void {
		__cached = false;
	}

/* === Computed Instance Fields === */

	/* The 'x' Coordinate of [this] Entity */
	public var x(get, set):Float;
	private inline function get_x() return position.x;
	private inline function set_x(nx : Float) return (position.x = nx);

	/* The 'y' Coordinate of [this] Entity */
	public var y(get, set):Float;
	private inline function get_y() return position.y;
	private inline function set_y(nt : Float) return (position.y = nt);

	/* The 'z' Coordinate of [this] Entity */
	public var z(get, set):Float;
	private inline function get_z() return position.z;
	private inline function set_z(nz : Float) return (position.z = nz);

	/* The 'width' of [this] Entity */
	public var width(get, set):Float;
	private inline function get_width() return area.width;
	private inline function set_width(nw : Float) return (area.width = nw);
	
	/* The 'height' of [this] Entity */
	public var height(get, set):Float;
	private inline function get_height() return area.height;
	private inline function set_height(nh : Float) return (area.height = nh);

	/* A Rectangle for [this] Entity */
	public var rectangle(get, set):Rectangle;
	private inline function get_rectangle() return new Rectangle(x, y, width, height);
	private function set_rectangle(nr : Rectangle) {
		x = nr.x;
		y = nr.y;
		z = nr.z;
		width = nr.w;
		height = nr.h;
		return nr;
	}

/* === Instance Fields === */

	/* The Coordinates of [this] Entity */
	public var position : Point;

	/* The Area [this] Entity Covers */
	public var area : Area;

	/* The Stage [this] Entity is attached to */
	private var root : Null<Stage>;

	/* Whether [this] Entity is flagged for deletion */
	private var __remove : Bool;

	/* Whether [this] Entity is flagged as cached */
	private var __cached : Bool;
}
