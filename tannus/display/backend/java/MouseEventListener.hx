package tannus.display.backend.java;

import tannus.display.backend.java.*;
import tannus.display.TGraphics;
import tannus.geom.*;
import tannus.io.Ptr;
import tannus.io.Signal;
import tannus.ds.Maybe;

import tannus.events.MouseEvent;
import tannus.events.EventMod;
import tannus.events.EventCreator;

import java.awt.event.MouseListener;
import java.awt.event.MouseMotionListener;

class MouseEventListener implements MouseListener implements MouseMotionListener implements EventCreator {
	/* Constructor Function */
	public function new(_w : Window):Void {
		win = _w;
	}

/* === Instance Methods === */

	/**
	  * Create a Tannus Event from a Java Event
	  */
	private function createTannusEvent(e:JMouseEvent, type:String):MouseEvent {
		var mods:Array<EventMod> = new Array();
		
		if (e.isShiftDown()) mods.push( Shift );
		if (e.isAltDown()) mods.push( Alt );
		if (e.isControlDown()) mods.push( Control );
		if (e.isMetaDown()) mods.push( Meta );

		var p = e.getPoint();
		var pos:Point = ([p.x, p.y]);
		
		var mevent:MouseEvent = new MouseEvent(type, pos, e.getButton(), mods);
		return mevent;
	}

	/**
	  * Dispatch a MouseEvent to the Window
	  */
	private inline function fire(me : MouseEvent):Void {
		win.mouseEvent.broadcast( me );
	}

/* === MouseListener Methods === */

	/**
	  * Mouse-Down Event
	  */
	public function mousePressed(event : JMouseEvent):Void {
		var e = createTannusEvent(event, 'mousedown');
		fire( e );
	}
	
	/**
	  * Mouse-Up Event
	  */
	public function mouseReleased(event : JMouseEvent):Void {
		fire(createTannusEvent(event, 'mouseup'));
	}
	
	/**
	  * Mouse-Click Event
	  */
	public function mouseClicked(event : JMouseEvent):Void {
		fire(createTannusEvent(event, 'click'));
	}

	/**
	  * Mouse-Enter Event
	  */
	public function mouseEntered(event : JMouseEvent):Void {
		fire(createTannusEvent(event, 'mouseenter'));
	}

	/**
	  * Mouse-Leave Event
	  */
	public function mouseExited(event : JMouseEvent):Void {
		fire(createTannusEvent(event, 'mouseleave'));
	}

	/**
	  * Mouse-Move Event
	  */
	public function mouseMoved(event : JMouseEvent):Void {
		fire(createTannusEvent(event, 'mousemove'));
	}

	/**
	  * Mouse-Drag Event
	  */
	public function mouseDragged(event : JMouseEvent):Void {
		fire(createTannusEvent(event, 'mousedrag'));
	}

/* === Instance Fields === */

	//- reference to the Window [this] is attached to
	private var win : Window;
}

typedef JMouseEvent = java.awt.event.MouseEvent;
